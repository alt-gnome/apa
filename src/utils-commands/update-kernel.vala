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

public sealed class Apa.Kernel : Origin {

    protected override string origin { get; default = "/sbin/update-kernel"; }

    public const string KERNEL = "kernel";

    public const string[] COMMANDS = {
        KERNEL,
    };

    const string UPDATE = "update";
    const string LIST = "list";

    Kernel () {}

    public static async int run (
        Gee.ArrayList<string> subcommands,
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (subcommands.size == 0) {
            Help.print_kernel ();
            return Constants.ExitCode.BASE_ERROR;
        }

        return yield new Kernel ().internal_run (subcommands[0], options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_run (
        string subcommand,
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        switch (subcommand) {
            case UPDATE:
                break;

            case LIST:
                spawn_arr.add ("--list");
                break;

            default:
                throw new CommandError.UNKNOWN_COMMAND (_("Unknown command '%s'").printf (subcommand));
        }

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
}
