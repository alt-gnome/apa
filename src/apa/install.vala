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
    internal async int install (owned CommandArgs ca) throws CommonCommandError, CommandError {
        while (true) {
            var error = new Gee.ArrayList<string> ();
            var status = yield Get.install (ca.command_argv, ca.options, ca.arg_options, error);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package_error_source;

                switch (detect_error (error_message, out package_error_source)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        print (_("Some packages not found"));

                        var total_search_result = new Gee.ArrayList<string> ();
                        yield Cache.search ({ "." }, {}, total_search_result);
                        do_short_array_list (ref total_search_result);
                        var all_packages_set = new Gee.HashSet<string> ();
                        all_packages_set.add_all (total_search_result);

                        for (int arg_i = 0; arg_i < ca.command_argv.length; arg_i++) {
                            var package_name = ca.command_argv[arg_i];

                            if (package_name in all_packages_set) {
                                continue;
                            }

                            var package_name_straight = package_name.replace ("-", "");

                            var search_result = new Gee.ArrayList<string> ();
                            yield Cache.search (
                                { string.joinv (".*", split_chars (package_name_straight)) },
                                { "--names-only" },
                                search_result
                            );
                            do_short_array_list (ref search_result);

                            string[]? possible_package_names = fuzzy_search (package_name_straight, search_result.to_array ());

                            if (possible_package_names == null) {
                                print_error (_("Package '%s' not found").printf (package_name));
                                return status;
                            }

                            print (_("A packages with a similar name were found:"));
                            string? answer;
                            var result = give_choice (possible_package_names, _("install"), out answer);

                            switch (result) {
                                case ChoiceResult.SKIP:
                                    remove_element_from_array (ref ca.command_argv, package_name);
                                    if (ca.command_argv.length == 0) {
                                        print (_("There are no packages left to install"));
                                        return 0;
                                    }
                                    break;

                                case ChoiceResult.CHOSEN:
                                    ca.command_argv[arg_i] = answer;
                                    break;

                                case ChoiceResult.EXIT:
                                    return status;
                            }
                        }
                        break;

                    case OriginErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
                        error_message = error_message[0:error_message.length - 2] + ":";
                        print (error_message);

                        var packages = new Gee.ArrayList<string> ();
                        foreach (var err in error) {
                            if (err.has_prefix ("  ")) {
                                string[] strs = err.strip ().split (" ");
                                if (strs[strs.length - 1].has_suffix ("]") && strs[strs.length - 1].has_prefix ("[")) {
                                    packages.add ("%s (%s)".printf (
                                        strs[0],
                                        strs[strs.length - 1][1: strs[strs.length - 1].length - 1]
                                    ));

                                } else {
                                    packages.add (strs[0]);
                                }
                            }
                        }

                        string? answer;
                        var result = give_choice (packages.to_array (), _("install"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                remove_element_from_array (ref ca.command_argv, package_error_source);
                                if (ca.command_argv.length == 0) {
                                    print (_("There are no packages left to install"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array (ref ca.command_argv, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.NONE:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_issue ();
                        return Constants.ExitCode.BASE_ERROR;

                    default:
                        assert_not_reached ();
                }

            } else {
                return status;
            }
        }
    }
}
