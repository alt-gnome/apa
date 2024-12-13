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

namespace Apa.UpdateKernel {

    const string ORIGIN = "/sbin/update-kernel";

    public const string UPDATE = "update";
    public const string LIST = "list";

    public static async int update (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, null);

        command.fill_by_args_handler (
            args_handler,
            OptionData.concat (UpdateKernel.Data.COMMON_OPTIONS_DATA, UpdateKernel.Data.UPDATE_OPTIONS_DATA),
            OptionData.concat (UpdateKernel.Data.COMMON_ARG_OPTIONS_DATA, UpdateKernel.Data.UPDATE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int list (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, UPDATE);

        command.spawn_vector.add ("--list");

        command.fill_by_args_handler (
            args_handler,
            OptionData.concat (UpdateKernel.Data.COMMON_OPTIONS_DATA, UpdateKernel.Data.UPDATE_OPTIONS_DATA),
            OptionData.concat (UpdateKernel.Data.COMMON_ARG_OPTIONS_DATA, UpdateKernel.Data.UPDATE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }
}
