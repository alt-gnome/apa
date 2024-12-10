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

public sealed class Apa.Command : Object {

    public string origin { get; construct; }

    public string? command { get; construct; default = null; }

    public Gee.ArrayList<string> spawn_vector { get; private set; }

    public Command (string origin, string? command = null) {
        Object (origin: origin, command: command);
    }

    construct {
        spawn_vector = new Gee.ArrayList<string>.wrap ({ origin });

        if (command != null) {
            spawn_vector.add (command);
        }
    }

    /**
     * Put translated apa options to ORIGIN-like format into {@link spawn_vector}
     */
    public void fill_by_args_handler (
        ArgsHandler args_handler,
        OptionData[] possible_options_data,
        OptionData[] possible_arg_options_data,
        bool skip_unknown_options = false
    ) throws OptionsError {
        foreach (var option in args_handler.options) {
            var option_data = OptionData.find_option (possible_options_data, option);
            if (option_data == null) {
                if (!skip_unknown_options) {
                    throw new OptionsError.UNKNOWN_OPTION (option);
                }

            } else {
                spawn_vector.add (option_data.target_option);
            }
        }

        foreach (ArgOption arg_option in args_handler.arg_options) {
            var option_data = OptionData.find_option (possible_arg_options_data, arg_option.name);
            if (option_data == null) {
                if (!skip_unknown_options) {
                    throw new OptionsError.UNKNOWN_ARG_OPTION (arg_option.name);
                }

            } else {
                if (option_data.target_option.has_prefix ("--")) {
                    spawn_vector.add (option_data.target_option + "=" + arg_option.value);

                } else {
                    spawn_vector.add (option_data.target_option);
                    spawn_vector.add (arg_option.value);
                }
            }
        }
    }

    /**
     * Put translated apa options to ORIGIN-like format into {@link spawn_vector} with args.
     * {@link ArgsHandler.args} must not be empty.
     */
    public void fill_by_args_handler_with_args (
        ArgsHandler args_handler,
        OptionData[] possible_options_data,
        OptionData[] possible_arg_options_data,
        bool skip_unknown_options = false
    ) throws OptionsError {
        assert (args_handler.args.size != 0);

        fill_by_args_handler (args_handler, possible_options_data, possible_arg_options_data, skip_unknown_options);

        spawn_vector.add_all (args_handler.args);
    }
}
