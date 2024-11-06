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
    internal async int upgrade (
        owned Gee.ArrayList<string> options,
        owned Gee.ArrayList<ArgOption?> arg_options,
        bool ignore_unknown_options = false
    ) throws CommandError {
        var error = new Gee.ArrayList<string> ();
        int status;

        if ("--with-kernel" in options || "-k" in options) {
            status = yield kernel (
                new Gee.ArrayList<string>.wrap ({ "update" }),
                options,
                arg_options,
                true
            );

            if (status != Constants.ExitCode.SUCCESS) {
                return status;
            }

            options.remove ("--with-kernel");
            options.remove ("-k");

        } else {
            status = yield update (options, arg_options, true);
            
            if (status != Constants.ExitCode.SUCCESS) {
                return status;
            }
        }

        while (true) {
            error.clear ();

            status = yield Get.upgrade (options, arg_options, error);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {
                string error_message = normalize_error (error);
                string? package;

                switch (detect_error (error_message, out package)) {
                    case OriginErrorType.UNABLE_TO_LOCK_DOWNLOAD_DIR:
                        print_error (_("APT is currently busy"));
                        return status;

                    case OriginErrorType.UNABLE_TO_FETCH_SOME_ARCHIVES:
                        print_error (_("Unable to fetch some archives. Check your connection to repository. Maybe run 'apa update' or try with '--fix-missing' option"));
                        return status;

                    case OriginErrorType.NONE:
                    default:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_create_issue (error_message, form_command (
                            error_message,
                            Get.UPGRADE,
                            {},
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
