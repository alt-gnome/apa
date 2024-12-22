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
    public async int remove (
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
        }

        while (true) {
            var status = yield AptGet.remove (args_handler, error, skip_unknown_options);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string[] error_sources;

                switch (detect_error (error_message, out error_sources)) {
                    case OriginErrorType.COULDNT_FIND_PACKAGE:
                        var package_error_source = error_sources[0];

                        if (!ConfigManager.get_default ().use_fuzzy_search) {
                            print_error (_("Package `%s' not found").printf (package_error_source));
                            return status;
                        }

                        var installed_result = new Gee.ArrayList<string> ();
                        //  yield Rpm.list (
                        //      new ArgsHandler ({ "--queryformat=%{NAME}" }),
                        //      installed_result
                        //  );

                        string[]? possible_package_names = fuzzy_search (package_error_source, installed_result.to_array (), 9);

                        if (possible_package_names == null) {
                            print_error (_("Package `%s' not found").printf (package_error_source));
                            return status;
                        }

                        print (_("Package `%s' not found, but packages with a similar name were found").printf (package_error_source));
                        string? answer;
                        var result = give_choice (possible_package_names, _("to remove"), out answer);

                        switch (result) {
                            case ChoiceResult.SKIP:
                                args_handler.args.remove (package_error_source);
                                if (args_handler.args.size == 0) {
                                    throw new CommandError.NO_PACKAGES_LEFT (_("There are no packages left to remove"));
                                }
                                break;

                            case ChoiceResult.CHOSEN:
                                replace_strings_in_array_list (
                                    args_handler.args,
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

                    case OriginErrorType.CONFIGURATION_ITEM_SPECIFICATION_MUST_HAVE_AN_VAL:
                        print_error (_("Option `-o/--option' value is incorrect. It should look like `OptionName=val'"));
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
