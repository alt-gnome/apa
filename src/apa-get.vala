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

    public static void install (string[] packages, string[] options) {
        var a = new Array<string> ();

        a.append_val ("apt-get");
        a.append_val ("install");
        a.append_vals (options, options.length);
        a.append_vals (packages, packages.length);

        spawn_command (a.data);
    }

    public static void remove (string[] packages, string[] options) {
        var a = new Array<string> ();

        a.append_val ("apt-get");
        a.append_val ("remove");
        a.append_vals (options, options.length);
        a.append_vals (packages, packages.length);

        spawn_command (a.data);
    }
}
