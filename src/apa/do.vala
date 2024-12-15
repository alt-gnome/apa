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
    public async int @do (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var error = new Gee.ArrayList<string> ();

        args_handler.check_args_size (null);

        foreach (var package_name in args_handler.args) {
            if (!package_name.has_suffix ("-") && !package_name.has_suffix ("+")) {
                throw new CommandError.COMMON (_("Unknown operation `%c' in `%s'").printf (
                    package_name[package_name.length - 1],
                    package_name
                ));
            }
        }

        foreach (string package in args_handler.args) {
            if (package[package.length - 1] != '-' && package[package.length - 1] != '+') {
                throw new CommandError.COMMON (_("Don't known what to do with %s").printf (package));
            }
        }

        while (true) {
            var status = yield AptGet.do (args_handler, error);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package_error_source;

                switch (detect_error (error_message, out package_error_source)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        string package_error_source_name = package_error_source[0:package_error_source.length - 1];
                        char package_error_source_operation = package_error_source[package_error_source.length - 1];

                        string[]? possible_package_names;

                        switch (package_error_source_operation) {
                            case '+':
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
                                    do_short_array_list (ref search_result);

                                    possible_package_names = fuzzy_search (package_error_source, search_result.to_array ());

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
                                    do_short_array_list (ref search_result);

                                    possible_package_names = search_result.to_array ();

                                    if (possible_package_names.length == 0) {
                                        possible_package_names = null;
                                    } else if (possible_package_names.length > 9) {
                                        possible_package_names.resize (9);
                                    }
                                }
                                break;

                            case '-':
                                var installed_result = new Gee.ArrayList<string> ();
                                yield Rpm.list (
                                    new ArgsHandler ({ "-s" }),
                                    installed_result
                                );

                                possible_package_names = fuzzy_search (package_error_source, installed_result.to_array ());
                                break;

                            default:
                                assert_not_reached ();
                        }

                        print (_("Package `%s' not found, but packages with a similar name were found").printf (package_error_source));
                        string? answer;
                        var result = give_choice (possible_package_names, _("to remove"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                args_handler.args.remove (package_error_source);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to do"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (
                                    args_handler.args,
                                    package_error_source,
                                    answer.split (" ")[0] + package_error_source_operation.to_string ()
                                );
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
                        string do_package = find_package_in_do_list (args_handler.args, package_error_source);
                        char package_error_source_operation = do_package[do_package.length - 1];

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
                                args_handler.args.remove (do_package);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to do"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (
                                    args_handler.args,
                                    do_package,
                                    answer.split (" ")[0] + package_error_source_operation.to_string ()
                                );
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.NO_INSTALLATION_CANDIDAT:
                        string do_package = find_package_in_do_list (args_handler.args, package_error_source);
                        char package_error_source_operation = do_package[do_package.length - 1];

                        print (error_message.replace (package_error_source, "`%s'".printf (package_error_source)));

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
                        var result_choice = give_choice (choice_packages.to_array (), _("to install"), out answer);

                        switch (result_choice) {
                            case ChoiceResult.SKIP:
                                args_handler.args.remove (do_package);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to do"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (
                                    args_handler.args,
                                    do_package,
                                    answer.split (" ")[0] + package_error_source_operation.to_string ()
                                );
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.UNABLE_TO_FETCH_SOME_ARCHIVES:
                        print_error (_("Unable to fetch some archives. Check your connection to repository. Maybe run `apa update' or try with `--fix-missing' option"));
                        return status;

                    case OriginErrorType.CONFIGURATION_ITEM_SPECIFICATION_MUST_HAVE_AN_VAL:
                        print_error (_("Option `-o/--option' value is incorrect. It should look like OptionName=val"));
                        return status;

                    case OriginErrorType.OPEN_CONFIGURATION_FILE_FAILED:
                        print_error (_("Option `-c/--config' value is incorrect"));
                        return status;

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
