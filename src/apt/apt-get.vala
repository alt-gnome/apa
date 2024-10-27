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

public sealed class Apa.Get : Origin {

    protected override string origin { get; default = "apt-get"; }

    public const string UPDATE = "update";
    public const string UPGRADE = "upgrade";
    public const string INSTALL = "install";
    public const string REMOVE = "remove";
    public const string SOURCE = "source";

    public const string[] COMMANDS = {
        UPDATE,
        UPGRADE,
        INSTALL,
        REMOVE,
        SOURCE,
    };

    Get () {}

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
                    "-h", "--hide-progress",
                    "-q"
                },
                {
                    "-q", "--quiet",
                    "-qq"
                },
                {
                    "-s", "--simulate",
                    "-s"
                },
                {
                    "-y", "--yes",
                    "-y"
                },
                {
                    "-f", "--fix",
                    "-f"
                },
                {
                    "-V", "--version-detailed",
                    "-V"
                }
            }
        );
    }

    public static async int update (
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new Get ().internal_update (options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_update (
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

        spawn_arr.add (UPDATE);

        return yield spawn_command (spawn_arr, error);
    }

    public static async int upgrade (
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        return yield new Get ().internal_upgrade (options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_upgrade (
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
                    "-d", "--download-only",
                    "-d"
                },
                {
                    "-u", "--upgraded-show",
                    "-u"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add ("dist-upgrade");

        return yield spawn_command (spawn_arr, error);
    }

    public static async int install (
        string[] packages,
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (packages.length == 0) {
            Help.print_install ();
            throw new CommandError.NO_PACKAGES (_("No packages to install"));
        }

        return yield new Get ().internal_install (packages, options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_install (
        string[] packages,
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
                    "-d", "--download-only",
                    "-d"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add (INSTALL);
        spawn_arr.add_all_array (packages);

        return yield spawn_command (spawn_arr, error);
    }

    public static async int remove (
        string[] packages,
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (packages.length == 0) {
            Help.print_remove ();
            throw new CommandError.NO_PACKAGES (_("No packages to remove"));
        }

        return yield new Get ().internal_remove (packages, options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_remove (
        string[] packages,
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
                    "-D", "--with-dependecies",
                    "-D"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add (REMOVE);
        spawn_arr.add_all_array (packages);

        return yield spawn_command (spawn_arr, error);
    }

    public static async int source (
        string[] packages,
        string[] options = {},
        ArgOption?[] arg_options = {},
        Gee.ArrayList<string>? error = null,
        bool ignore_unknown_options = false
    ) throws CommandError {
        if (packages.length == 0) {
            Help.print_source ();
            throw new CommandError.NO_PACKAGES (_("No packages to download"));
        }

        return yield new Get ().internal_source (packages, options, arg_options, error, ignore_unknown_options);
    }

    public async int internal_source (
        string[] packages,
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
                    "-b", "--build",
                    "-b"
                }
            }
        );

        if (!ignore_unknown_options) {
            post_set_check ();
        }

        spawn_arr.add (SOURCE);
        spawn_arr.add_all_array (packages);

        return yield spawn_command (spawn_arr, error);
    }
}