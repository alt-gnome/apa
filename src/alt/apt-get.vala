/*
 * Copyright 2024 Rirusha
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

    internal const string INSTALL_COMMAND = "install";
    internal const string REMOVE_COMMAND = "remove";
    internal const string UPDATE_COMMAND = "update";

    const string[] COMMANDS = {
        INSTALL_COMMAND,
        REMOVE_COMMAND,
        UPDATE_COMMAND
    };

    public async int install (string[] packages, string[] options = {}) {
        int base_length = 6;

        string[] arr = new string[base_length + packages.length + options.length] {
            ORIGIN,
            INSTALL_COMMAND,
            // https://bugzilla.altlinux.com/44670
            "-o", "APT::Install::VirtualVersion=true",
            "-o", "APT::Install::Virtual=true"
        };

        for (int i = 0; i < options.length; i++) {
            switch (options[i]) {
                case "-d":
                case "--download-only":
                    arr[i + base_length] = "-d";
                    break;

                default:
                    print (_("Command line option '%s' is not known.\n"), options[i]);
                    return 1;
            }
        }

        for (int i = 0; i < packages.length; i++) {
            arr[i + options.length + base_length] = packages[i];
        }

        return yield spawn_command (arr);
    }

    public async int remove (string[] packages, string[] options = {}) {
        int base_length = 2;

        string[] arr = new string[base_length + packages.length + options.length] {
            ORIGIN,
            REMOVE_COMMAND
        };

        for (int i = 0; i < options.length; i++) {
            switch (options[i]) {
                case "-d":
                case "--download-only":
                    arr[i + base_length] = "-d";
                    break;

                default:
                    print (_("Command line option '%s' is not known.\n"), options[i]);
                    return 1;
            }
        }

        for (int i = 0; i < packages.length; i++) {
            arr[i + options.length + base_length] = packages[i];
        }

        return yield spawn_command (arr);
    }

    public async int update () {
        int base_length = 2;

        string[] arr = new string[base_length] {
            ORIGIN,
            UPDATE_COMMAND
        };

        return yield spawn_command (arr);
    }

    public void print_help (string command) {
        switch (command) {
            case INSTALL_COMMAND:
                print_install_help ();
                return;
            
            case REMOVE_COMMAND:
                print_remove_help ();
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
}
