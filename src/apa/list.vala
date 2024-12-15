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
    public async int list (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var result = new Gee.ArrayList<string> ();
        var error = new Gee.ArrayList<string> ();

        bool is_sort = false;

        foreach (var option in args_handler.options) {
            var option_data = OptionEntity.find_option (Rpm.Data.list_options (), option);

            switch (option_data.short_option) {
                case Rpm.Data.OPTION_SORT_SHORT:
                    is_sort = true;
                    args_handler.options.remove (Rpm.Data.OPTION_SORT_SHORT);
                    args_handler.options.remove (Rpm.Data.OPTION_SORT_LONG);
                    break;

                case Rpm.Data.OPTION_SHORT_SHORT:
                    args_handler.options.remove (Rpm.Data.OPTION_LAST_SHORT);
                    args_handler.options.remove (Rpm.Data.OPTION_LAST_LONG);
                    break;
            }
        }

        while (true) {
            result.clear ();
            error.clear ();

            var status = yield Rpm.list (args_handler, result, error, skip_unknown_options);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package;

                switch (detect_error (error_message, out package)) {
                    case OriginErrorType.NONE:
                    default:
                        throw new CommandError.UNKNOWN_ERROR (error_message);
                }

            } else {
                if (is_sort) {
                    result.sort ();
                }

                foreach (var line in result) {
                    print (line);
                }

                return status;
            }
        }
    }
}
