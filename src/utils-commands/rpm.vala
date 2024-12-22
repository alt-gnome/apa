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

namespace Apa.Rpm {

    const string ORIGIN = "rpm";

    public const string LIST = "list";
    public const string INFO = "info";

    public static async string[] list () {
        var command = new Command (ORIGIN);

        command.spawn_vector.add ("-q");
        command.spawn_vector.add ("-a");

        var result = new Gee.ArrayList<string> ();
        yield spawn_command_full (command.spawn_vector, result, null);

        if (result != null) {
            for (int i = 0; i < result.size; i++) {
                result[i] = result[i].strip ();
            }
        }

        return result.to_array ();
    }

    public static async string[] info (
        string[] rpm_names
    ) {
        var command = new Command (ORIGIN);

        command.spawn_vector.add ("-q");
        command.spawn_vector.add ("-i");
        command.spawn_vector.add_all_array (rpm_names);

        var result = new Gee.ArrayList<string> ();
        yield spawn_command_full (command.spawn_vector, result, null);

        return result.to_array ();
    }

    /**
     * Filename HAVE TO exist
     */
    public static async string? serch_file (
        string filename
    ) {
        var command = new Command (ORIGIN);

        command.spawn_vector.add ("-q");
        command.spawn_vector.add ("-f");
        command.spawn_vector.add (filename);

        var result = new Gee.ArrayList<string> ();
        if ((yield spawn_command_full (command.spawn_vector, result, null)) != 0) {
            return null;
        }

        if (result.size == 0) {
            return null;
        }

        return result.to_array ()[0];
    }
}
