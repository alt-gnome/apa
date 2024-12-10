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
    public async int info (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        while (true) {
            var error = new Gee.ArrayList<string> ();

            args_handler.init_options (
                OptionData.concat (Rpm.Data.COMMON_OPTIONS_DATA, Rpm.Data.INFO_OPTIONS_DATA),
                OptionData.concat (Rpm.Data.COMMON_ARG_OPTIONS_DATA, Rpm.Data.INFO_ARG_OPTIONS_DATA),
                skip_unknown_options
            );

            if (args_handler.args.size == 0) {
                throw new CommandError.NO_PACKAGES (_("Nothing to show"));
            }

            var status = yield Rpm.info (args_handler, null, error, skip_unknown_options);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package;

                switch (detect_error (error_message, out package)) {
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
