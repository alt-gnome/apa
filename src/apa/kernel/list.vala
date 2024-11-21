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
    public async int kernel_list (
        owned CommandHandler command_handler,
        bool ignore_unknown_options = false
    ) throws CommandError {
        var error = new Gee.ArrayList<string> ();
        int status;

        while (true) {
            error.clear ();
            status = yield UpdateKernel.list (command_handler, error, ignore_unknown_options);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);

                switch (detect_error (error_message)) {
                    case OriginErrorType.NONE:
                    default:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_create_issue (error_message, command_handler);
                        return Constants.ExitCode.BASE_ERROR;
                }

            } else {
                return status;
            }
        }
    }
}
