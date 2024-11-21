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

 public sealed class Apa.Cache : Origin {

    protected override string origin { get; default = "apt-cache"; }

    public const string SEARCH = "search";

    Cache () {}

    void set_common_options () {
        assert (spawn_arr != null);
        assert (current_options != null);
        assert (current_arg_options != null);

        set_options (
            ref spawn_arr,
            current_options,
            current_arg_options,
            {
                {
                    "-o", "--option",
                    "-o"
                },
                {
                    "-c", "--config",
                    "-c"
                },
                {
                    "-p", "--package-cache",
                    "-p"
                },
                {
                    "-s", "--source-cache",
                    "-s"
                },
                {
                    "-h", "--hide-progress",
                    "-q"
                },
                {
                    "-i", "--important-only",
                    "-i"
                }
            }
        );
    }

    public static async int list_all (
        owned CommandHandler command_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new Cache ().internal_search (
            new Gee.ArrayList<string>.wrap ({ "." }),
            command_handler.options,
            command_handler.arg_options,
            result,
            error,
            ignore_unknown_options
        );
    }

    public static async int search (
        owned CommandHandler command_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (command_handler.argv.size == 0) {
            throw new CommandError.NO_PACKAGES (_("No packages to search"));
        }

        return yield new Cache ().internal_search (
            command_handler.argv,
            command_handler.options,
            command_handler.arg_options,
            result,
            error,
            ignore_unknown_options
        );
    }

    public async int internal_search (
        Gee.ArrayList<string> regexs,
        Gee.ArrayList<string> options,
        Gee.ArrayList<ArgOption?> arg_options,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all (options);
        current_arg_options.add_all (arg_options);

        set_common_options ();

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add (SEARCH);
        spawn_arr.add_all (regexs);

        return yield spawn_command_full (spawn_arr, result, error);
    }
}
