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

public sealed class Apa.Repo : Origin {

    protected override string origin { get; default = "apt-repo"; }

    public const string REPO_LIST = "repo-list";
    public const string TEST = "test";

    public const string[] COMMANDS = {
        REPO_LIST,
        TEST,
    };

    Repo () {}

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
                    "-s", "--simulate",
                    "--dry-run"
                },
                {
                    "-h", "--hsh-apt-config",
                    "--hsh-apt-config"
                },
            }
        );

        foreach (var arg_option in current_arg_options) {
            if (arg_option.name == "-c" || arg_option.name == "--config") {
                spawn_arr.insert (0, "APT_CONFIG=%s".printf (arg_option.value));
                current_arg_options.remove (arg_option);
                break;
            }
        }
    }

    public static async int test (
        string[] tasks,
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (tasks.length == 0) {
            Help.print_test ();
            throw new CommandError.NO_PACKAGES (_("No packages to install"));
        }

        return yield new Repo ().internal_test (tasks, options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_test (
        string[] tasks,
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all_array (options);
        current_arg_options.add_all_array (arg_options);

        set_common_options ();

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add (TEST);
        spawn_arr.add_all_array (tasks);

        return yield spawn_command (spawn_arr, error);
    }

    public static async int repo_list (
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new Repo ().internal_repo_list (options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_repo_list (
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        current_options.add_all_array (options);
        current_arg_options.add_all_array (arg_options);

        set_common_options ();
        set_options (
            ref spawn_arr,
            current_options,
            current_arg_options,
            {
                {
                    "-a", "--all",
                    "-a"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add ("list");

        return yield spawn_command (spawn_arr, error);
    }
}
