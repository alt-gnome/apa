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

public sealed class Apa.Rpm : Origin {

    protected override string origin { get; default = "rpm"; }

    public const string LIST = "list";
    public const string INFO = "info";

    public const string[] COMMANDS = {
        LIST,
        INFO,
    };

    Rpm () {}

    public static async int list (
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new Rpm ().internal_list (options, arg_options, result, error, ignore_unknown_options);
    }

    public async int internal_list (
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all_array (options);
        current_arg_options.add_all_array (arg_options);

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

        return yield spawn_command_full (spawn_arr, result, error);
    }

    public static async int info (
        string[] packages = {},
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (packages.length == 0) {
            throw new CommandError.NO_PACKAGES (_("No packages to show"));
        }

        return yield new Rpm ().internal_info (packages, options, arg_options, result, error, ignore_unknown_options);
    }

    public async int internal_info (
        string[] packages = {},
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all_array (options);
        current_arg_options.add_all_array (arg_options);

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

        spawn_arr.add_all_array (packages);

        return yield spawn_command_full (spawn_arr, result, error);
    }
}
