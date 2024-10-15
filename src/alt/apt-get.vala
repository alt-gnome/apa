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

    internal const string ORIGIN = "apt-get";

    internal const string INSTALL = "install";
    internal const string REMOVE = "remove";
    internal const string UPDATE = "update";

    const string[] COMMANDS = {
        INSTALL,
        REMOVE,
        UPDATE
    };

    public async int install (string[] packages,
                              string[] options = {},
                              Gee.ArrayList<string>? error = null) {
        var arr = new Gee.ArrayList<string>.wrap ({
            ORIGIN,
            INSTALL,
            // https://bugzilla.altlinux.com/44670
            "-o", "APT::Install::VirtualVersion=true",
            "-o", "APT::Install::Virtual=true"
        });

        bool is_quiet = false;

        foreach (string option in options) {
            switch (option) {
                case "-d":
                case "--download-only":
                    arr.add ("-d");
                    break;

                case "-q":
                case "--quiet":
                    is_quiet = true;
                    break;

                default:
                    print (_("Command line option \"%s\" is not known.\n").printf (option));
                    return 1;
            }
        }

        arr.add_all_array (packages);

        return yield spawn_command (arr, error);
    }

    public async int remove (string[] packages,
                             string[] options = {},
                             Gee.ArrayList<string>? error = null) {
        var arr = new Gee.ArrayList<string>.wrap ({
            ORIGIN,
            REMOVE
        });

        bool is_quiet = false;

        foreach (string option in options) {
            switch (option) {
                case "-D":
                case "--with-dependecies":
                    arr.add ("-D");
                    break;

                case "-q":
                case "--quiet":
                    is_quiet = true;
                    break;

                default:
                    print (_("Command line option \"%s\" is not known.\n").printf (option));
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

        bool is_quiet = false;

        foreach (string option in options) {
            switch (option) {
                case "-q":
                case "--quiet":
                    is_quiet = true;
                    break;

                default:
                    print (_("Command line option \"%s\" is not known.\n").printf (option));
                    return 1;
            }
        }

        return yield spawn_command (arr, error);
    }

    public void print_help (string command) {
        switch (command) {
            case INSTALL:
                print_install_help ();
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

    internal void print_install_help () {
        print ("Install help\n");
    }

    internal void print_remove_help () {
        print ("Remove help\n");
    }

    internal void print_update_help () {
        print ("Update help\n");
    }
}
