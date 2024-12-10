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
    public async int upgrade (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var error = new Gee.ArrayList<string> ();
        int status;

        args_handler.init_options (
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.UPGRADE_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.UPGRADE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        if ("--with-kernel" in args_handler.options || "-k" in args_handler.options) {
            status = yield kernel_upgrade (args_handler.copy (), true);

            if (status != ExitCode.SUCCESS) {
                return status;
            }

            args_handler.options.remove ("--with-kernel");
            args_handler.options.remove ("-k");

        } else {
            status = yield update (args_handler.copy (), true);

            if (status != ExitCode.SUCCESS) {
                return status;
            }
        }

        while (true) {
            error.clear ();

            status = yield Get.upgrade (args_handler, error, skip_unknown_options);

            if (status != ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package;

                switch (detect_error (error_message, out package)) {
                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.UNABLE_TO_FETCH_SOME_ARCHIVES:
                        print_error (_("Unable to fetch some archives. Check your connection to repository. Maybe run `apa update' or try with `--fix-missing' option"));
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
