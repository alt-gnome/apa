/*
 * Copyright (C) 2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Apa {
    public async int search (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var error = new Gee.ArrayList<string> ();
        var result = new Gee.ArrayList<string> ();

        args_handler.check_args_size (false, null);

        bool installed = false;
        bool names_only = false;

        foreach (var option in args_handler.options) {
            var option_data = OptionEntity.find_option (AptCache.Data.search_options (), option);

            switch (option_data.short_option) {
                case AptCache.Data.OPTION_INSTALLED_SHORT:
                    installed = true;
                    break;

                case AptCache.Data.OPTION_NAMES_ONLY_SHORT:
                    names_only = true;
                    break;
            }
        }

        for (int i = 0; i < args_handler.args.size; i++) {
            args_handler.args[i] = fix_regex (args_handler.args[i]);
        }

        if (installed) {
            while (true) {
                result.clear ();
                error.clear ();

                var status = yield Rpm.list (
                    new ArgsHandler.with_data (
                        {},
                        {
                            { name: Rpm.Data.OPTION_QUERYFORMAT_LONG, value: "%{NAME} - %{SUMMARY}\n" }
                        },
                        {}
                    ),
                    result,
                    error,
                    skip_unknown_options
                );

                if (status != ExitCode.SUCCESS && error.size > 0) {
                    string error_message = normalize_error (error);
                    string[] error_sources;

                    switch (detect_error (error_message, out error_sources)) {
                        case OriginErrorType.NONE:
                        default:
                            throw new CommandError.UNKNOWN_ERROR (error_message);
                    }

                } else {
                    var search_result = new Gee.ArrayList<string> ();
                    var matches = new Gee.ArrayList<string> ();

                    foreach (var package_info in parse_search (result.to_array ())) {
                        bool name_good = false;
                        bool desc_good = false;
                        matches.clear ();

                        foreach (var pattern in args_handler.args) {
                            try {
                                var regex = new Regex (
                                    pattern,
                                    RegexCompileFlags.OPTIMIZE,
                                    RegexMatchFlags.NOTEMPTY
                                );
                                MatchInfo match_info;

                                if (!name_good) {
                                    if (regex.match (package_info.name, 0, out match_info)) {
                                        name_good = true;
                                        matches.add_all_array (match_info.fetch_all ());
                                    }
                                }

                                if (!names_only && !desc_good) {
                                    if (regex.match (package_info.description, 0, out match_info)) {
                                        desc_good = true;
                                        matches.add_all_array (match_info.fetch_all ());
                                    }
                                }

                            } catch (Error e) {
                                throw new CommandError.COMMON (e.message);
                            }
                        }

                        if (name_good || desc_good) {
                            if (names_only) {
                                search_result.add ("%s - %s".printf (
                                    mark_text (package_info.name, matches.to_array ()),
                                    package_info.description
                                ));

                            } else {
                                search_result.add (mark_text (
                                    package_info.to_string (),
                                    matches.to_array ()
                                ));
                            }
                        }
                    }

                    foreach (var line in search_result) {
                        print (line);
                    }

                    return status;
                }
            }

        } else {
            while (true) {
                error.clear ();
                var status = yield AptCache.search (args_handler, result, error);

                if (status != ExitCode.SUCCESS && error.size > 0) {
                    string error_message = normalize_error (error);
                    string[] error_sources;

                    switch (detect_error (error_message, out error_sources)) {
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
                    var search_result = new Gee.ArrayList<string> ();
                    var matches = new Gee.ArrayList<string> ();
                    var regexes = new Gee.ArrayList<Regex> ();

                    foreach (var pattern in args_handler.args) {
                        try {
                            regexes.add (new Regex (
                                pattern,
                                RegexCompileFlags.CASELESS | RegexCompileFlags.OPTIMIZE,
                                RegexMatchFlags.NOTEMPTY
                            ));

                        } catch (Error e) {
                            throw new CommandError.COMMON (e.message);
                        }
                    }

                    foreach (var package_info in parse_search (result.to_array ())) {
                        bool name_good = false;
                        bool desc_good = false;

                        matches.clear ();

                        foreach (var regex in regexes) {
                            MatchInfo match_info;

                            if (!name_good) {
                                if (regex.match (package_info.name, 0, out match_info)) {
                                    name_good = true;
                                    matches.add_all_array (match_info.fetch_all ());
                                }
                            }

                            if (!names_only && !desc_good) {
                                if (regex.match (package_info.description, 0, out match_info)) {
                                    desc_good = true;
                                    matches.add_all_array (match_info.fetch_all ());
                                }
                            }
                        }

                        if (name_good || desc_good) {
                            if (names_only) {
                                search_result.add ("%s - %s".printf (
                                    mark_text (package_info.name, matches.to_array ()),
                                    package_info.description
                                ));

                            } else {
                                search_result.add (mark_text (
                                    package_info.to_string (),
                                    matches.to_array ()
                                ));
                            }
                        }
                    }

                    foreach (var line in search_result) {
                        print (line);
                    }

                    return status;
                }
            }
        }
    }
}
