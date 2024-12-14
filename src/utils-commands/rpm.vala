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

namespace Apa.Rpm {

    const string ORIGIN = "rpm";

    public const string LIST = "list";
    public const string INFO = "info";

    public static async int list (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN);

        command.spawn_vector.add ("-q");
        command.spawn_vector.add ("-a");

        command.fill_by_args_handler (
            args_handler,
            Rpm.Data.list_options (),
            Rpm.Data.list_arg_options (),
            skip_unknown_options
        );

        var status = yield spawn_command_full (command.spawn_vector, result, error);

        if (result != null) {
            for (int i = 0; i < result.size; i++) {
                result[i] = result[i].strip ();
            }
        }

        return status;
    }

    public static async int info (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN);

        command.spawn_vector.add ("-q");
        command.spawn_vector.add ("-i");

        command.fill_by_args_handler_with_args (
            args_handler,
            Rpm.Data.info_options (),
            Rpm.Data.info_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command_full (command.spawn_vector, result, error);
    }

    public static async int serch_file (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN);

        command.spawn_vector.add ("-q");
        command.spawn_vector.add ("-f");

        command.fill_by_args_handler_with_args (
            args_handler,
            Rpm.Data.common_options (),
            Rpm.Data.common_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command_full (command.spawn_vector, result, error);
    }
}
