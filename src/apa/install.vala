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
        owned CommandHandler command_handler,
        bool ignore_unknown_options = false
    ) throws CommandError {
        var error = new Gee.ArrayList<string> ();

        foreach (string package_name in command_handler.argv) {
            if (!(yield check_package_name_no_action (package_name))) {
                print_error (_("For operation like '<package>+/-' use 'do' command instead"));
                return Constants.ExitCode.BASE_ERROR;
            }
        }

        while (true) {
            error.clear ();
            var status = yield Get.install (command_handler, error, null, ignore_unknown_options);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package_error_source;

                switch (detect_error (error_message, out package_error_source)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        var search_result = new Gee.ArrayList<string> ();
                        yield Cache.search (
                            new CommandHandler () {
                                argv = new Gee.ArrayList<string>.wrap ({ string.joinv (".*", split_chars (package_error_source)) }),
                                // Options not ->
                                options = new Gee.ArrayList<string>.wrap ({ "--names-only" }),
                                arg_options = command_handler.arg_options
                            },
                            search_result,
                            null,
                            true
                        );
                        do_short_array_list (ref search_result);

                        string[]? possible_package_names = fuzzy_search (package_error_source, search_result.to_array ());

                        if (possible_package_names == null) {
                            print_error (_("Package '%s' not found").printf (package_error_source));
                            return status;
                        }

                        print (_("Package '%s' not found, but packages with a similar name were found").printf (package_error_source));
                        string? answer;
                        var result = give_choice (possible_package_names, _("install"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                command_handler.argv.remove (package_error_source);
                                if (command_handler.argv.size == 0) {
                                    print (_("There are no packages left to install"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (command_handler.argv, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
                        print (error_message[0:error_message.length - 1].replace (package_error_source, "'%s'".printf (package_error_source)));

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
                        var result = give_choice (choice_packages.to_array (), _("install"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                command_handler.argv.remove (package_error_source);
                                if (command_handler.argv.size == 0) {
                                    print (_("There are no packages left to install"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (command_handler.argv, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.NO_INSTALLATION_CANDIDAT:
                        print (error_message.replace (package_error_source, "'%s'".printf (package_error_source)));

                        // FIXME: need move error part of message to cerr in apt
                        var result = new Gee.ArrayList<string> ();
                        yield Get.install (command_handler, error, result, ignore_unknown_options);

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

                        var result_choice = give_choice (choice_packages.to_array (), _("install"), out answer);

                        switch (result_choice) {
                            case ChoiceResult.SKIP:
                                command_handler.argv.remove (package_error_source);
                                if (command_handler.argv.size == 0) {
                                    print (_("There are no packages left to install"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (command_handler.argv, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_FETCH_SOME_ARCHIVES:
                        print_error (_("Unable to fetch some archives. Check your connection to repository. Maybe run 'apa update' or try with '--fix-missing' option"));
                        return status;

                    case OriginErrorType.NONE:
                    default:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_create_issue (error_message, command_handler);
                        return Constants.ExitCode.BASE_ERROR;
                }

            } else {
                return status;
            }
        }
    }
}
