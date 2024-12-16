/*
 * Copyright 2024 Vladimir Vaskov
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Apa {
    public async int install (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var error = new Gee.ArrayList<string> ();

        args_handler.check_args_size (false, null);

        foreach (string package_name in args_handler.args) {
            if (!(yield check_package_name_no_action (package_name))) {
                print_error (_("For operation like `<package>+/-' use `do' command instead"));
                return ExitCode.BASE_ERROR;
            }

            if (Regex.match_simple ("^#{0,1}\\d*$", package_name, RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY)) {
                var task = package_name.replace ("#", "");

                print (_("Found task `%s' in packages. Skipping other").printf (package_name.replace ("#", "")));

                return yield Task.install (
                    new ArgsHandler.with_data (
                        args_handler.options.to_array (),
                        args_handler.arg_options.to_array (),
                        { task }
                    ),
                    true
                );
            }
        }

        while (true) {
            error.clear ();
            var status = yield AptGet.install (args_handler, error, null);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string[] error_sources;

                switch (detect_error (error_message, out error_sources)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        var package_error_source = error_sources[0];

                        string[]? possible_package_names;

                        if (ConfigManager.get_default ().use_fuzzy_search) {
                            var search_result = new Gee.ArrayList<string> ();
                            yield AptCache.search (
                                new ArgsHandler.with_data (
                                    { "--names-only" },
                                    args_handler.arg_options.to_array (),
                                    { string.joinv (".*", split_chars (package_error_source)) }
                                ),
                                search_result
                            );
                            var package_names = new Gee.ArrayList<string> ();
                            foreach (var package_info in parse_search (search_result.to_array ())) {
                                package_names.add (package_info.name);
                            }

                            possible_package_names = fuzzy_search (package_error_source, package_names.to_array (), 9);

                        } else {
                            var search_result = new Gee.ArrayList<string> ();
                            yield AptCache.search (
                                new ArgsHandler.with_data (
                                    { "--names-only" },
                                    args_handler.arg_options.to_array (),
                                    { package_error_source }
                                ),
                                search_result
                            );
                            var package_names = new Gee.ArrayList<string> ();
                            foreach (var package_info in parse_search (search_result.to_array ())) {
                                package_names.add (package_info.name);
                            }

                            possible_package_names = package_names.to_array ();

                            if (possible_package_names.length == 0) {
                                possible_package_names = null;
                            } else if (possible_package_names.length > 9) {
                                possible_package_names.resize (9);
                            }
                        }

                        if (possible_package_names == null) {
                            print_error (_("Package `%s' not found").printf (package_error_source));
                            return status;
                        }

                        print (_("Package `%s' not found, but packages with a similar name were found").printf (package_error_source));
                        string? answer;
                        var result = give_choice (possible_package_names, _("to install"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                args_handler.args.remove (package_error_source);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to install"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (args_handler.args, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
                        var package_error_source = error_sources[0];

                        print (error_message[0:error_message.length - 1].replace (package_error_source, "`%s'".printf (package_error_source)));

                        var choice_packages = new Gee.ArrayList<string> ();
                        foreach (var err in error) {
                            if (err.has_prefix ("  ")) {
                                string[] strs = err.strip ().split (" ");
                                if (strs[strs.length - 1].has_suffix ("]") && strs[strs.length - 1].has_prefix ("[")) {
                                    choice_packages.add ("%s (%s)".printf (
                                        strs[0],
                                        strs[strs.length - 1][1: strs[strs.length - 1].length - 1]
                                    ));

                                } else {
                                    choice_packages.add (strs[0]);
                                }
                            }
                        }

                        string? answer;
                        var result = give_choice (choice_packages.to_array (), _("to install"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                args_handler.args.remove (package_error_source);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to install"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (args_handler.args, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.NO_INSTALLATION_CANDIDAT:
                        var package_error_source = error_sources[0];

                        print (error_message.replace (package_error_source, "`%s'".printf (package_error_source)));

                        // FIXME: need move error part of message to cerr in apt
                        var result = new Gee.ArrayList<string> ();
                        yield AptGet.install (args_handler, error, result);

                        var choice_packages = new Gee.ArrayList<string> ();
                        foreach (var res in result) {
                            if (res.has_prefix ("  ")) {
                                string[] strs = res.strip ().split (" ");
                                if (strs[strs.length - 1].has_suffix ("]") && strs[strs.length - 1].has_prefix ("[")) {
                                    choice_packages.add ("%s (%s)".printf (
                                        strs[0],
                                        strs[strs.length - 1][1: strs[strs.length - 1].length - 1]
                                    ));

                                } else {
                                    choice_packages.add (strs[0]);
                                }
                            }
                        }

                        string? answer;
                        if (choice_packages.size == 0) {
                            print_error (error_message);
                            return status;
                        }

                        var result_choice = give_choice (choice_packages.to_array (), _("to install"), out answer);

                        switch (result_choice) {
                            case ChoiceResult.SKIP:
                                args_handler.args.remove (package_error_source);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to install"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (args_handler.args, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_FETCH_SOME_ARCHIVES:
                        throw new CommandError.COMMON (_("Unable to fetch some archives. Check your connection to repository. Run `apa update' or try use `--fix-missing' option"));

                    case OriginErrorType.CONFIGURATION_ITEM_SPECIFICATION_MUST_HAVE_AN_VAL:
                        throw new CommandError.COMMON (_("Option `-o/--option' value is incorrect. It should look like `OptionName=val'"));

                    case OriginErrorType.TASK_IS_UNKNOWN_OR_STILL_BUILDING:
                        throw new CommandError.TASK_IS_UNKNOWN (error_sources[0]);

                    case OriginErrorType.OPEN_CONFIGURATION_FILE_FAILED:
                        throw new CommandError.COMMON (_("Option `-c/--config' value is incorrect"));

                    case OriginErrorType.VERSION_NOT_FOUND:
                        throw new CommandError.COMMON (error_message);

                    case OriginErrorType.BROKEN_PACKAGES:
                        throw new CommandError.COMMON (_("Broken packages. Running `apa update' can help you"));

                    case OriginErrorType.NONE:
                    default:
                        throw new CommandError.UNKNOWN_ERROR (error_message);
                }

            } else {
                return status;
            }
        }
    }
}
