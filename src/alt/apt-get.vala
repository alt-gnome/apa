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

namespace Apa.Get {

    public errordomain CommandError {
        NO_PACKAGES
    }

    internal const string ORIGIN = "apt-get";

    internal const string INSTALL = "install";
    internal const string REMOVE = "remove";
    internal const string UPDATE = "update";

    const string[] COMMANDS = {
        INSTALL,
        REMOVE,
        UPDATE
    };

    //  bool hide_progress;
    //  bool quiet;
    //  bool simulate;
    //  bool yes;
    //  bool fix;
    //  bool detailed_version;

    public void set_common_options (
        ref Gee.ArrayList<string> spawn_arr,
        Gee.ArrayList<string> current_options,
        Gee.ArrayList<ArgOption?> current_arg_options
    ) {
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

    public async int install (string[] packages,
                              string[] options = {},
                              ArgOption?[] arg_options = {},
                              Gee.ArrayList<string>? error = null) throws CommonCommandError, CommandError {
        if (packages.length == 0) {
            print (Help.INSTALL, false);
            throw new CommandError.NO_PACKAGES (_("No packages to install"));
        }

        var spawn_arr = new Gee.ArrayList<string>.wrap ({ ORIGIN, INSTALL });
        var current_options = new Gee.ArrayList<string>.wrap (options);
        var current_arg_options = new Gee.ArrayList<ArgOption?>.wrap ((ArgOption?[]) arg_options, (el1, el2) => {
            return el1.name == el2.name && el1.value == el2.value;
        });

        if ("-N" in current_options || "--no-virtual" in current_options) {
            current_options.remove ("-N");
            current_options.remove ("--no-virtual");

        } else {
            // https://bugzilla.altlinux.com/44670
            current_arg_options.add_all_array ({
                { "-o", "APT::Install-Recommends=false" },
                { "-o", "APT::AutoRemove::RecommendsImportant=false" }
            });
        }

        set_common_options (ref spawn_arr, current_options, current_arg_options);
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
                    "-b", "--build",
                    "-b"
                }
            }
        );

        foreach (var current_option in current_options) {
            throw new CommonCommandError.UNKNOWN_OPTION (_("Unknown option '%s'").printf (current_option));
        }
        foreach (var current_arg_option in current_arg_options) {
            throw new CommonCommandError.UNKNOWN_OPTION (_("Unknown option with value '%s'").printf (
                current_arg_option.name
            ));
        }

        spawn_arr.add_all_array (packages);

        return yield spawn_command (spawn_arr, error);
    }

    public async int remove (string[] packages,
                             string[] options = {},
                             Gee.ArrayList<string>? error = null) {
        var arr = new Gee.ArrayList<string>.wrap ({
            ORIGIN,
            REMOVE
        });

        foreach (string option in options) {
            switch (option) {
                case "-D":
                case "--with-dependecies":
                    arr.add ("-D");
                    break;

                default:
                    print (_("Unknown option '%s'").printf (option));
                    return 1;
            }
        }

        arr.add_all_array (packages);

        return yield spawn_command (arr, error);
    }

    public async int update (string[] options = {},
                             Gee.ArrayList<string>? error = null) {
        var arr = new Gee.ArrayList<string>.wrap ({
            ORIGIN,
            UPDATE
        });

        foreach (string option in options) {
            switch (option) {
                case "-u":
                case "--updatable-show":
                    arr.add ("-u");
                    break;

                default:
                    print (_("Unknown option '%s'").printf (option));
                    return 1;
            }
        }

        return yield spawn_command (arr, error);
    }



    public void print_help (string command) {
        switch (command) {
            case INSTALL:
                print (Help.INSTALL, false);
                return;

            case REMOVE:
                print_remove_help ();
                return;

            case UPDATE:
                print_update_help ();
                return;

            default:
                assert_not_reached ();
        }
    }

    internal void print_remove_help () {
        print ("Remove help");
    }

    internal void print_update_help () {
        print ("Update help");
    }
}
