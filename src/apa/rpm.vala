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

    public async int list (string[] options = {},
                           bool is_silence = false,
                           Gee.ArrayList<string>? result = null,
                           Gee.ArrayList<string>? error = null) {
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
                    print (_("Command line option \"%s\" is not known.\n").printf (option));
                    return 1;
            }
        }

        return yield spawn_command_full (arr, is_silence, result, error);
    }

    public async int info (string package_name,
                           string[] options = {},
                           bool is_silence = false,
                           Gee.ArrayList<string>? result = null,
                           Gee.ArrayList<string>? error = null) {
        var arr = new Gee.ArrayList<string>.wrap ({ ORIGIN, "-q" });

        if (options.length == 0) {
            arr.add_all_array ({ "-i" });

        }

        foreach (string option in options) {
            switch (option) {
                case "-f":
                case "--files":
                    arr.add ("-l");
                    break;

                default:
                    print (_("Command line option \"%s\" is not known.\n").printf (option));
                    return 1;
            }
        }

        arr.add (package_name);

        return yield spawn_command_full (arr, is_silence, result, error);
    }
}
