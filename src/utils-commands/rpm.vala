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

public sealed class Apa.Rpm : Origin {

    protected override string origin { get; default = "rpm"; }

    public const string LIST = "list";
    public const string INFO = "info";

    Rpm () {}

    public static async int list (
        owned OptionsHandler command_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new Rpm ().internal_list (
            command_handler.options,
            command_handler.arg_options,
            result,
            error,
            ignore_unknown_options
        );
    }

    public async int internal_list (
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all (options);
        current_arg_options.add_all (arg_options);

        spawn_arr.add ("-q");
        spawn_arr.add ("-a");

        set_options (
            ref spawn_arr,
            current_options,
            current_arg_options,
            {
                {
                    "-s", "--short",
                    "--queryformat=%{NAME}\n"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        var status = yield spawn_command_full (spawn_arr, result, error);

        if (result != null) {
            for (int i = 0; i < result.size; i++) {
                result[i] = result[i].strip ();
            }
        }

        return status;
    }

    public static async int info (
        owned ArgvHandler command_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (command_handler.argv.size == 0) {
            throw new CommandError.NO_PACKAGES (_("No packages to show"));
        }

        return yield new Rpm ().internal_info (
            command_handler.argv,
            command_handler.options,
            command_handler.arg_options,
            result,
            error,
            ignore_unknown_options
        );
    }

    public async int internal_info (
        Gee.ArrayList<string> packages,
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all (options);
        current_arg_options.add_all (arg_options);

        spawn_arr.add ("-q");
        spawn_arr.add ("-i");

        set_options (
            ref spawn_arr,
            current_options,
            current_arg_options,
            {
                {
                    "-f", "--files",
                    "-l"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add_all (packages);

        return yield spawn_command_full (spawn_arr, result, error);
    }
}
