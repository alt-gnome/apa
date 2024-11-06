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
    internal async int remove (
        owned Gee.ArrayList<string> packages,
        owned Gee.ArrayList<string> options,
        owned Gee.ArrayList<ArgOption?> arg_options
    ) throws CommandError {
        foreach (string package_name in packages) {
            if (package_name.has_suffix ("-") || package_name.has_suffix ("+")) {
                print_error (_("For operation like '<package>+/-' use 'do' command instead"));
                return Constants.ExitCode.BASE_ERROR;
            }
        }

        while (true) {
            var error = new Gee.ArrayList<string> ();
            var status = yield Get.remove (packages, options, arg_options, error);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package_error_source;
                switch (detect_error (error_message, out package_error_source)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        var package_name_straight = package_error_source.replace ("-", "");

                        var installed_result = new Gee.ArrayList<string> ();
                        yield Rpm.list (
                            new Gee.ArrayList<string>.wrap ({ "-s" }),
                            new Gee.ArrayList<ArgOption?> (),
                            installed_result
                        );

                        string[]? possible_package_names = fuzzy_search (package_name_straight, installed_result.to_array ());

                        if (possible_package_names == null) {
                            print_error (_("Package '%s' not found").printf (package_error_source));
                            return status;
                        }

                        print (_("Package '%s' not found, but packages with a similar name were found:").printf (package_error_source));
                        string? answer;
                        var result = give_choice (possible_package_names, _("remove"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                packages.remove (package_error_source);
                                if (packages.size == 0) {
                                    print (_("There are no packages left to remove"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (
                                    ref packages,
                                    package_error_source,
                                    answer.split (" ")[0]
                                );
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.NONE:
                    default:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_create_issue (error_message, form_command (
                            Get.REMOVE,
                            packages.to_array (),
                            options.to_array (),
                            arg_options.to_array ()
                        ));
                        return Constants.ExitCode.BASE_ERROR;
                }

            } else {
                return status;
            }
        }
    }
}
