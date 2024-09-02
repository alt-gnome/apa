/*
 * Copyright (C) 2024 Rirusha
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

namespace Apa {
    
    internal const string ORIGIN = "rpm";

    public async int list (string[] options = {}) {
        var arr = new string[3 + options.length];

        arr[0] = ORIGIN;
        arr[1] = "-q";
        arr[2] = "-a";

        for (int i = 0; i < options.length; i++) {
            switch (options[i]) {
                case "-a":
                case "--all":
                    arr[i + 3] = "-a";
                    break;

                default:
                    print (_("Command line option '%s' is not known.\n"), options[i]);
                    return 1;
            }
        }

        return yield spawn_command (arr);
    }
}
