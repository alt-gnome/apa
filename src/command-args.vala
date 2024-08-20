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

public struct Apa.CommandArgs {

    public string command;
    public string[] command_argv;
    public string[] options;

    public static CommandArgs parse (ref string[] argv) {
        var command = "";
        var command_argv_array = new Array<string> ();
        var options_array = new Array<string> ();

        foreach (var arg in argv) {
            if (arg.has_prefix ("-") || arg.has_prefix ("--")) {
                options_array.append_val (arg);

            } else if (command == "") {
                command = arg;

            } else {
                command_argv_array.append_val (arg);
            }
        }

        return {
            command,
            command_argv_array.data,
            options_array.data
        };
    }
}
