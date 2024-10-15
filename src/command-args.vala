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

public struct Apa.ArgOption {
    public string name;
    public string value;
}

public struct Apa.CommandArgs {

    public string? command;
    public string[] command_argv;
    public string[] options;
    public ArgOption[] arg_options;

    public static CommandArgs parse (string[] argv) {
        string? command = null;
        var command_argv_array = new Gee.ArrayList<string> ();
        var options_array = new Gee.ArrayList<string> ();
        var arg_options_array = new Gee.ArrayList<ArgOption?> ();

        foreach (var arg in argv) {
            if ("=" in arg) {
                var arg_option_div = arg.split ("=");
                arg_options_array.add ({ arg_option_div[0], arg_option_div[1] });
            }

            if (arg.has_prefix ("--")) {
                options_array.add (arg);

            } else if (arg.has_prefix ("-")) {
                foreach (char c in (char[]) (arg.data)) {
                    if (c != '-') {
                        options_array.add (c.to_string ("-%c"));
                    }
                };

            } else if (command == null) {
                command = arg;

            } else {
                command_argv_array.add (arg);
            }
        }

        return {
            command,
            command_argv_array.to_array (),
            options_array.to_array (),
            (ArgOption[]) arg_options_array.to_array ()
        };
    }
}
