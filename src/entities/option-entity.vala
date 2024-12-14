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

public struct Apa.OptionEntity {

    public string short_option;
    public string long_option;
    public string target_option;
    public string description;

    public bool contain (string option) {
        return option == short_option || option == long_option;
    }

    public static OptionEntity?[] concat (OptionEntity?[] arr1, OptionEntity?[] arr2) {
        OptionEntity?[] new_arr = new OptionEntity?[arr1.length + arr2.length];

        for (int i = 0; i < arr1.length; i++) {
            new_arr[i] = arr1[i];
        }

        for (int i = arr1.length; i < new_arr.length; i++) {
            new_arr[i] = arr2[i - arr1.length];
        }

        return new_arr;
    }

    public static OptionEntity? find_option (OptionEntity?[] options, string option) {
        foreach (var opt in options) {
            if (opt.short_option == option || opt.long_option == option) {
                return opt;
            }
        }

        return null;
    }

    public static bool equal (OptionEntity? a, OptionEntity? b) {
        return a?.short_option == b?.short_option && a?.long_option == b?.long_option;
    }
}
