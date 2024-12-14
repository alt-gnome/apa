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

using Apa.Commands.Data;

namespace Apa.Help {

    const string BASE_INDENT = "  ";

    void print_command_help (string? command, string? subcommand) {
        if (command == null) {
            print_apa ();
            return;
        }

        var entity = CommandEntity.find (all_commands (), command);
        if (entity == null) {
            print_error (_("No help for `%s'").printf (command));
            return;
        }

        if (subcommand != null) {
            if (entity.subcommands != null) {
                var sub_entity = CommandEntity.find (entity.subcommands.to_array (), subcommand);
                print_subcommand (sub_entity.description, sub_entity.options.to_array (), sub_entity.arg_options.to_array ());

            } else {
                print_error (_("No help for `%s %s'").printf (command, subcommand));
            }

        } else {
            if (entity.subcommands != null) {
                print_command (entity.description, entity.subcommands.to_array ());

            } else {
                print_subcommand (entity.description, entity.options.to_array (), entity.arg_options.to_array ());
            }
        }
    }

    string indx (uint x) {
        var builder = new StringBuilder ();
        for (uint i = 0; i < x; i++) {
            builder.append (BASE_INDENT);
        }
        return builder.free_and_steal ();
    }

    public void print_apa () {
        print_command (
            Descriptions.apa (),
            all_commands ()
        );
    }

    void print_command (
        string description,
        CommandEntity[] commands_data
    ) {
        print (description);

        print ("");
        print (_("Available commands:"));
        foreach (var entry in commands_data) {
            print ("%s%s - %s".printf (
                indx (1),
                bold_text (entry.name),
                entry.description
            ));
        }
    }

    void print_subcommand (
        string description,
        OptionEntity?[] options_data,
        OptionEntity?[] arg_options_data,
        string[] usage = {}
    ) {
        print (description);

        print ("");
        foreach (var option_data in options_data) {
            print ("%s%s, %s".printf (
                indx (1),
                option_data.short_option,
                option_data.long_option
            ));

            print (indx (2) + option_data.description);
            print ("");
        }

        foreach (var option_data in arg_options_data) {
            print ("%s%s ?, %s=?".printf (
                indx (1),
                option_data.short_option,
                option_data.long_option
            ));

            print (indx (2) + option_data.description);
            print ("");
        }
    }
}
