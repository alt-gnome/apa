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

namespace Apa.Rpm {

    internal const string ORIGIN = "rpm";

    public int list (
        string[] options = {},
        Gee.ArrayList<string>? result = null
    ) {
        var arr = new Gee.ArrayList<string>.wrap ({
            ORIGIN,
            "-q", "-a"
        });

        foreach (string option in options) {
            switch (option) {
                case "-q":
                case "--query":
                    arr.add ("-q");
                    break;

                case "-a":
                case "--all":
                    arr.add ("-a");
                    break;

                default:
                    print (_("Command line option \"%s\" is not known.\n"), option);
                    return 1;
            }
        }

        return spawn_command_with_result (arr.to_array (), result);
    }

    public int info (
        string package_name,
        string[] options = {},
        Gee.ArrayList<string>? result = null
    ) {
        var arr = new Gee.ArrayList<string>.wrap ({ ORIGIN, "-i" });

        if (options.length == 0) {
            arr.add_all_array ({ "-q" });

        }

        foreach (string option in options) {
            switch (option) {
                case "-f":
                case "--files":
                    arr.add ("-l");
                    break;

                default:
                    print (_("Command line option \"%s\" is not known.\n"), option);
                    return 1;
            }
        }

        arr.add (package_name);

        return spawn_command_with_result (arr.to_array (), result);
    }
}
