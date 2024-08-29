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

    internal const string COMMAND = "apt-cache";

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
        var arr = new string[3 + options.length];

        arr[0] = COMMAND;
        arr[1] = SEARCH_COMMAND;

        for (int i = 0; i < options.length; i++) {
            arr[i + 2] = options[i];
        }

        for (int i = 0; i < regexs.length; i++) {
            arr[i + 2 + options.length] = regexs[i];
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
