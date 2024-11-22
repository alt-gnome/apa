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

public sealed class Apa.UpdateKernel : Origin {

    protected override string origin { get; default = "/sbin/update-kernel"; }

    public const string UPDATE = "update";
    public const string LIST = "list";

    UpdateKernel () {}

    public static async int update (
        owned OptionsHandler command_handler,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new UpdateKernel ().internal_update (command_handler.options, command_handler.arg_options, error, ignore_unknown_options);
    }

    public async int internal_update (
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all (options);
        current_arg_options.add_all (arg_options);

        set_options (
            ref spawn_arr,
            current_options,
            current_arg_options,
            {
                {
                    "-A", "--add-module",
                    "-A"
                },
                {
                    "-D", "--del-module",
                    "-D"
                },
                {
                    "-F", "--force",
                    "-f"
                },
                {
                    "-d", "--download-only",
                    "-d"
                },
                {
                    "-s", "--simulate",
                    "-n"
                },
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        return yield spawn_command (spawn_arr, error);
    }

    public static async int list (
        owned OptionsHandler command_handler,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new UpdateKernel ().internal_list (command_handler.options, command_handler.arg_options, error, ignore_unknown_options);
    }

    public async int internal_list (
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all (options);
        current_arg_options.add_all (arg_options);

        spawn_arr.add ("--list");

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        return yield spawn_command (spawn_arr, error);
    }
}
