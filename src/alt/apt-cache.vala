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

namespace Apa.Cache {

    internal const string ORIGIN = "apt-cache";

    internal const string SEARCH = "search";

    const string[] COMMANDS = {
        SEARCH
    };

    public async int search (string[] regexs,
                             string[] options,
                             Gee.ArrayList<string>? result = null,
                             Gee.ArrayList<string>? error = null) {
        var arr = new Gee.ArrayList<string>.wrap ({
            ORIGIN,
            SEARCH
        });

        for (int i = 0; i < options.length; i++) {
            switch (options[i]) {
                case "-n":
                case "--names-only":
                    arr.add ("--names-only");
                    break;

                default:
                    print (_("Unknown option '%s'").printf (options[i]));
                    return 1;
            }
        }

        arr.add_all_array (regexs);

        return yield spawn_command_full (arr, result, error);
    }

    public void print_help (string command) {
        switch (command) {
            case SEARCH:
                print_search_help ();
                return;

            default:
                assert_not_reached ();
        }
    }

    internal void print_search_help () {
        print ("Search help");
    }
}
