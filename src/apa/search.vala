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
        args_handler.check_args_size (false, null);

        for (int i = 0; i < args_handler.args.size; i++) {
            args_handler.args[i] = fix_regex (args_handler.args[i]);
        }

        bool installed = false;
        bool names_only = false;

        foreach (var option in args_handler.options) {
            var option_data = OptionEntity.find_option (Search.Data.options (), option);

            switch (option_data.short_option) {
                case AptCache.Data.OPTION_INSTALLED_SHORT:
                    installed = true;
                    break;

                case AptCache.Data.OPTION_NAMES_ONLY_SHORT:
                    names_only = true;
                    break;
            }
        }

        var cachier = Cachier.get_default ();
        Package[] all_packages;

        if (installed) {
            all_packages = yield cachier.get_installed_packages ();

        } else {
            all_packages = yield cachier.get_all_packages ();
        }

        var search_result = new Gee.ArrayList<string> ();
        var matches = new Gee.ArrayList<string> ();
        var regexes = new Gee.ArrayList<Regex> ();

        foreach (var pattern in args_handler.args) {
            try {
                regexes.add (new Regex (
                    pattern,
                    RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS,
                    RegexMatchFlags.NOTEMPTY
                ));

            } catch (Error e) {
                throw new CommandError.COMMON (e.message);
            }
        }

        foreach (var package in all_packages) {
            bool name_good = false;
            bool desc_good = false;

            var package_name = package.name;
            var package_desc = package.summary;
            matches.clear ();

            foreach (var regex in regexes) {
                MatchInfo match_info;

                if (!name_good) {
                    if (regex.match (package_name, 0, out match_info)) {
                        name_good = true;
                        matches.add_all_array (match_info.fetch_all ());
                    }
                }

                if (!names_only && !desc_good) {
                    if (regex.match (package_desc, 0, out match_info)) {
                        desc_good = true;
                        matches.add_all_array (match_info.fetch_all ());
                    }
                }
            }

            if (name_good || desc_good) {
                if (names_only) {
                    search_result.add ("%s - %s".printf (
                        mark_text (package_name, matches.to_array ()),
                        package_desc
                    ));

                } else {
                    search_result.add (mark_text (
                        "%s - %s".printf (
                            package_name,
                            package_desc
                        ),
                        matches.to_array ()
                    ));
                }
            }
        }

        foreach (var line in search_result) {
            print (line);
        }

        return 0;
    }
}
