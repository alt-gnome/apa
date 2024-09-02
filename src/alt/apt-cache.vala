/*
 * Copyright (C) 2024 Rirusha
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

namespace Apa.Cache {

    internal const string ORIGIN = "apt-cache";

    internal const string SEARCH_COMMAND = "search";

    const string[] COMMANDS = {
        SEARCH_COMMAND
    };

    public async int search (
        string[] regexs,
        string[] options,
        bool is_short = false,
        Array<string>? result = null
    ) {
        int base_length = 2;

        string[] arr = new string[base_length + regexs.length + options.length] {
            ORIGIN,
            SEARCH_COMMAND
        };

        for (int i = 0; i < options.length; i++) {
            switch (options[i]) {
                case "-n":
                case "--names-only":
                    arr[i + base_length] = "--names-only";
                    break;

                default:
                    print (_("Command line option '%s' is not known.\n"), options[i]);
                    return 1;
            }
        }

        for (int i = 0; i < regexs.length; i++) {
            arr[i + options.length + base_length] = regexs[i];
        }

        var status = yield spawn_command (arr, result);

        if (is_short) {
            do_short_array (result);
        }

        return status;
    }

    public void print_help (string command) {
        switch (command) {
            case SEARCH_COMMAND:
                print_search_help ();
                return;

            default:
                assert_not_reached ();
        }
    }

    internal void print_search_help () {
        print ("Search help\n");
    }
}
