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

    const string[] COMMANDS = {
        INSTALL_COMMAND,
        REMOVE_COMMAND
    };

    public async int install (string[] packages, string[] options = {}) {
        var arr = new string[2 + packages.length + options.length];

        arr[0] = ORIGIN;
        arr[1] = INSTALL_COMMAND;

        for (int i = 0; i < options.length; i++) {
            arr[i + 2] = options[i];
        }

        for (int i = 0; i < packages.length; i++) {
            arr[i + 2 + options.length] = packages[i];
        }

        return yield spawn_command (arr);
    }

    public async int remove (string[] packages, string[] options = {}) {
        var arr = new string[2 + packages.length + options.length];

        arr[0] = ORIGIN;
        arr[1] = REMOVE_COMMAND;

        for (int i = 0; i < options.length; i++) {
            arr[i + 2] = options[i];
        }

        for (int i = 0; i < packages.length; i++) {
            arr[i + 2 + options.length] = packages[i];
        }

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
