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
                string? package;

                switch (detect_error (error_message, out package)) {
                    case ErrorType.COULDNT_FIND_PACKAGE:
                        print (_("Some packages not found"));

                        var search_result = new Gee.ArrayList<string> ();
                        yield Cache.search ({ "." }, {}, search_result);
                        do_short_array_list (ref search_result);
                        var all_packages_set = new Gee.HashSet<string> ();
                        all_packages_set.add_all (search_result);

                        for (int arg_i = 0; arg_i < ca.command_argv.length; arg_i++) {
                            var package_name = ca.command_argv[arg_i];

                            if (package_name in all_packages_set) {
                                continue;
                            }

                            var package_name_straight = package_name.replace ("-", "");

                            var result = new Gee.ArrayList<string> ();
                            yield Cache.search (
                                { string.joinv (".*", split_chars (package_name_straight)) },
                                { "--names-only" },
                                result
                            );
                            do_short_array_list (ref result);

                            string[]? possible_package_names = fuzzy_search (package_name_straight, result.to_array ());

                            if (possible_package_names == null) {
                                print_error (_("Package '%s' not found").printf (package_name));
                                return status;
                            }

                            print (_("A packages with a similar name were found:"));
                            var answer = give_choice (possible_package_names);

                            if (answer != null) {
                                ca.command_argv[arg_i] = answer;

                            } else {
                                return status;
                            }
                        }
                        break;

                    case ErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
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

                        var answer = give_choice (packages.to_array ());

                        if (answer != null) {
                            replace_strings_in_array (ref ca.command_argv, package, answer.split (" ")[0]);

                        } else {
                            return status;
                        }
                        break;

                    case ErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case ErrorType.NONE:
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
