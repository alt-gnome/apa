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

public class Apa.SubCommandHandler : CommandHandler {

    public string? subcommand { get; construct set; }

    public static SubCommandHandler convert_from_ch (owned CommandHandler command_handler) {
        string? subcommand = null;

        if (command_handler.argv.size != 0) {
            subcommand = command_handler.argv[0];
            command_handler.argv.remove_at (0);
        }

        return convert_from_ch_with_sc (command_handler, subcommand);
    }

    public static SubCommandHandler convert_from_ch_with_sc (owned CommandHandler command_handler, string subcommand) {
        return new SubCommandHandler () {
            command = command_handler.command,
            subcommand = subcommand,
            options = command_handler.options,
            arg_options = command_handler.arg_options,
            argv = command_handler.argv
        };
    }
}

public class Apa.CommandHandler : ArgvHandler {

    public string? command { get; set; }

    public static CommandHandler parse (string[] argv) {
        string? command = null;
        var command_argv_array = new Gee.ArrayList<string> ();
        var options_array = new Gee.ArrayList<string> ();
        var arg_options_array = new Gee.ArrayList<ArgOption?> ();

        foreach (var arg in argv) {
            if ("=" in arg) {
                var arg_option_div = arg.split ("=", 2);
                arg_options_array.add ({ arg_option_div[0], arg_option_div[1] });

            } else if (arg.has_prefix ("--")) {
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

        return new CommandHandler () {
            command = command,
            options = options_array,
            arg_options = arg_options_array,
            argv = command_argv_array
        };
    }
}

public class Apa.ArgvHandler : OptionsHandler {

    public Gee.ArrayList<string> argv { get; set; }
}

public class Apa.OptionsHandler : Object {

    public Gee.ArrayList<string> options { get; set; }

    public Gee.ArrayList<ArgOption?> arg_options { get; set; }
}
