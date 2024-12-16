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

public sealed class Apa.ArgsHandler : Object {

    /**
     * Raw argv array. Without command.
     */
    public string[] argv { get; construct; }

    /**
     * Parsed options. Not translated to ORIGIN-like format.
     */
    public Gee.ArrayList<string> options { get; construct; }

    /**
     * Parsed arg options. Not translated to ORIGIN-like format.
     */
    public Gee.ArrayList<ArgOption?> arg_options { get; construct; }

    /**
     * Parsed args.
     */
    public Gee.ArrayList<string> args { get; construct; }

    public ArgsHandler (string[] argv) {
        Object (
            argv: argv.copy (),
            options: new Gee.ArrayList<string> (),
            arg_options: new Gee.ArrayList<ArgOption?> (ArgOption.equal_func),
            args: new Gee.ArrayList<string> ()
        );
    }

    public ArgsHandler.with_data (
        string[] options,
        ArgOption?[] arg_options,
        string[] args
    ) {
        Object (
            argv: new string[0],
            options: new Gee.ArrayList<string>.wrap (options),
            arg_options: new Gee.ArrayList<ArgOption?>.wrap (arg_options, ArgOption.equal_func),
            args: new Gee.ArrayList<string>.wrap (args)
        );
    }

    public ArgsHandler.with_argv_and_data (
        string[] argv,
        string[] options,
        ArgOption?[] arg_options,
        string[] args
    ) {
        Object (
            argv: argv.copy (),
            options: new Gee.ArrayList<string>.wrap (options),
            arg_options: new Gee.ArrayList<ArgOption?>.wrap (arg_options, ArgOption.equal_func),
            args: new Gee.ArrayList<string>.wrap (args)
        );
    }

    public ArgsHandler copy () {
        return new ArgsHandler.with_argv_and_data (
            argv.copy (),
            options.to_array ().copy (),
            arg_options.to_array ().copy (),
            args.to_array ().copy ()
        );
    }

    public void init_options (
        OptionEntity?[] possible_options_data,
        OptionEntity?[] possible_arg_options_data
    ) throws OptionsError {
        for (int i = 0; i < argv.length; i++) {
            var arg = argv[i];

            if (arg.has_prefix ("--")) {
                var found_option = OptionEntity.find_option (possible_options_data, arg);
                if (found_option != null) {
                    options.add (arg);
                    continue;
                }

                var potential_arg_option = ArgOption.from_string (arg);

                found_option = OptionEntity.find_option (possible_arg_options_data, potential_arg_option.name);
                if (found_option != null) {
                    if (potential_arg_option.value == "") {
                        throw new OptionsError.NO_ARG_OPTION_VALUE (_("Option `%s' need value").printf (potential_arg_option.name));
                    }

                    arg_options.add (potential_arg_option);
                    continue;
                }

                throw new OptionsError.UNKNOWN_OPTION (arg);

            } else if (arg.has_prefix ("-")) {
                var found_option = OptionEntity.find_option (possible_options_data, arg);
                if (found_option != null) {
                    options.add (arg);
                    continue;
                }

                found_option = OptionEntity.find_option (possible_arg_options_data, arg);
                if (found_option != null) {
                    if (argv.length == i + 1) {
                        throw new OptionsError.NO_ARG_OPTION_VALUE (arg);
                    }
                    if (argv[i + 1].has_prefix ("-")) {
                        throw new OptionsError.NO_ARG_OPTION_VALUE (arg);
                    }

                    arg_options.add ({ name: arg, value: argv[i + 1] });
                    i++;
                    continue;
                }

                throw new OptionsError.UNKNOWN_OPTION (arg);

            } else {
                args.add (arg);
            }
        }
    }

    public void check_args_size (bool can_be_empty, int? max) throws CommandError {
        if (args.size == 0 && !can_be_empty) {
            throw new CommandError.TOO_FEW_ARGS ("");
        }

        if (max != null) {
            if (args.size > max) {
                throw new CommandError.TOO_MANY_ARGS ("");
            }
        }
    }

    public void remove_option (string name) {
        options.remove (name);
        arg_options.remove ({ name: name, value: "" });
    }
}
