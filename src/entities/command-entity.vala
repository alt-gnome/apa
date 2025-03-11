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

public sealed class Apa.CommandEntity : Object {

    public string name { get; construct; }

    public string description { get; construct; }

    public Gee.ArrayList<CommandEntity>? subcommands { get; construct; }

    public Gee.ArrayList<OptionEntity?> options { get; construct; }

    public Gee.ArrayList<OptionEntity?> arg_options { get; construct; }

    public bool need_root { get; construct; }

    public CommandEntity (
        string name,
        string description,
        OptionEntity?[] options,
        OptionEntity?[] arg_options,
        bool need_root
    ) {
        Object (
            name: name,
            description: description,
            subcommands: null,
            options: new Gee.ArrayList<OptionEntity?>.wrap (options.copy (), OptionEntity.equal),
            arg_options: new Gee.ArrayList<OptionEntity?>.wrap (arg_options.copy (), OptionEntity.equal),
            need_root: need_root
        );
    }

    public CommandEntity.root (
        string name,
        string description,
        CommandEntity[] subcommands
    ) {
        Object (
            name: name,
            description: description,
            subcommands: new Gee.ArrayList<CommandEntity>.wrap (subcommands.copy (), CommandEntity.equal)
        );
    }

    public static CommandEntity? find (CommandEntity[] command_entities, string name) {
        foreach (var command_entity in command_entities) {
            if (command_entity.name == name) {
                return command_entity;
            }
        }

        return null;
    }

    public static bool equal (CommandEntity a, CommandEntity b) {
        return a.name == b.name;
    }
}
