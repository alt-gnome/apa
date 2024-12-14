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

public struct Apa.ArgOption {

    public string name;
    public string value;

    public static ArgOption from_string (string str) {
        int delim_index = -1;

        for (int i = 0; i < str.length; i++) {
            if (str[i] == '=') {
                delim_index = i;
                break;
            }
        }

        if (delim_index == -1) {
            return { name: str, value: "" };

        } else {
            return { name: str[0:delim_index], value: str[delim_index + 1:str.length] };
        }
    }

    public static bool equal_func (ArgOption? a, ArgOption? b) {
        return a?.name == b?.name && a?.value == b?.value;
    }
}
