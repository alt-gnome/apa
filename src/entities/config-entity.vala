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

public struct Apa.ConfigEntity {

    public string name;
    public string description;
    public string possible_values_pattern;
    public string default_value;

    public static ConfigEntity? find (ConfigEntity[] config_entities, string name) {
        foreach (var config_entity in config_entities) {
            if (config_entity.name == name) {
                return config_entity;
            }
        }

        return null;
    }

    public static bool equal (ConfigEntity? a, ConfigEntity? b) {
        return a?.name == b?.name;
    }
}
