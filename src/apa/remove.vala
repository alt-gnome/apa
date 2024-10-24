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
    internal async int remove (owned CommandArgs ca) throws CommonCommandError, CommandError {
        while (true) {
            var error = new Gee.ArrayList<string> ();
            var status = yield Get.remove (ca.command_argv, ca.options, ca.arg_options, error);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package;

                switch (detect_error (error_message, out package)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        print (_("Some packages not found"));

                        var installed_result = new Gee.ArrayList<string> ();
                        yield Cache.search ({ "." }, {}, installed_result);
                        do_short_array_list (ref installed_result);
                        var all_packages_set = new Gee.HashSet<string> ();
                        all_packages_set.add_all (installed_result);

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

                    case OriginErrorType.NONE:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_issue ();
                        return Constants.ExitCode.BASE_ERROR;

                    default:
                        print (detect_error (error_message, out package).to_string ());
                        assert_not_reached ();
                }

            } else {
                return status;
            }
        }
    }
}
