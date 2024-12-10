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

namespace Apa.Kernel {
    public async int upgrade (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var error = new Gee.ArrayList<string> ();
        int status;

        args_handler.init_options (
            OptionData.concat (UpdateKernel.Data.COMMON_OPTIONS_DATA, UpdateKernel.Data.UPDATE_OPTIONS_DATA),
            OptionData.concat (UpdateKernel.Data.COMMON_ARG_OPTIONS_DATA, UpdateKernel.Data.UPDATE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        // TODO: Add config
        if (ConfigManager.get_default ().auto_update) {
            status = yield update (args_handler.copy (), true);

            if (status != ExitCode.SUCCESS) {
                return status;
            }
        }

        while (true) {
            error.clear ();
            status = yield UpdateKernel.update (args_handler, error, skip_unknown_options);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);

                switch (detect_error (error_message)) {
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
