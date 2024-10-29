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
    internal async int install (
        owned Gee.ArrayList<string> packages,
        owned Gee.ArrayList<string> options,
        owned Gee.ArrayList<ArgOption?> arg_options
    ) throws CommandError {
        var error = new Gee.ArrayList<string> ();

        foreach (string package_name in packages) {
            if (package_name.has_suffix ("-") || package_name.has_suffix ("+")) {
                print_error (_("For operation like '<package>+/- use 'do' commad instead'"));
                return Constants.ExitCode.BASE_ERROR;
            }
        }

        while (true) {
            error.clear ();
            var status = yield Get.install (packages, options, arg_options, error);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package_error_source;

                switch (detect_error (error_message, out package_error_source)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        var package_name_straight = package_error_source.replace ("-", "");

                        var search_result = new Gee.ArrayList<string> ();
                        yield Cache.search (
                            new Gee.ArrayList<string>.wrap ({ string.joinv (".*", split_chars (package_name_straight)) }),
                            new Gee.ArrayList<string>.wrap ({ "--names-only" }),
                            arg_options,
                            search_result,
                            null,
                            true
                        );
                        do_short_array_list (ref search_result);

                        string[]? possible_package_names = fuzzy_search (package_name_straight, search_result.to_array ());

                        if (possible_package_names == null) {
                            print_error (_("Package '%s' not found").printf (package_error_source));
                            return status;
                        }

                        print (_("Package %s not found, but packages with a similar name were found:").printf (package_error_source));
                        string? answer;
                        var result = give_choice (possible_package_names, _("install"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                packages.remove (package_error_source);
                                if (packages.size == 0) {
                                    print (_("There are no packages left to install"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (ref packages, package_error_source, answer.split (" ")[0]);
                                break;

                            case ChoiceResult.EXIT:
                                return status;
                        }
                        break;

                    case OriginErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
                        error_message = error_message[0:error_message.length - 2] + ":";
                        print (error_message);

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
                                packages.remove (package_error_source);
                                if (packages.size == 0) {
                                    print (_("There are no packages left to install"));
                                    return 0;
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (ref packages, package_error_source, answer.split (" ")[0]);
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
                        print_issue ();
                        return Constants.ExitCode.BASE_ERROR;
                }

            } else {
                return status;
            }
        }
    }
}
