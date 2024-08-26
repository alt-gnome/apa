/*
 * Copyright 2024 Rirusha
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

namespace Apa.Get {

    public async int install (string[] packages, string[] options) {
        var arr = new string[2 + packages.length + options.length];

        arr[0] = "apt-get";
        arr[1] = "install";

        for (int i = 0; i < options.length; i++) {
            arr[i + 2] = options[i];
        }

        for (int i = 0; i < packages.length; i++) {
            arr[i + 2 + options.length] = packages[i];
        }

        return yield spawn_command (arr);
    }

    public async int remove (string[] packages, string[] options) {
        var arr = new string[2 + packages.length + options.length];

        arr[0] = "apt-get";
        arr[1] = "remove";

        for (int i = 0; i < options.length; i++) {
            arr[i + 2] = options[i];
        }

        for (int i = 0; i < packages.length; i++) {
            arr[i + 2 + options.length] = packages[i];
        }

        return yield spawn_command (arr);
    }
}
