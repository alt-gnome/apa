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

public abstract class Apa.Origin : Object {

    protected virtual string origin { get; }

    protected Gee.ArrayList<string> spawn_arr;
    protected Gee.ArrayList<string> current_options;
    protected Gee.ArrayList<ArgOption?> current_arg_options;

    construct {
        spawn_arr = new Gee.ArrayList<string>.wrap ({ origin });
        current_options = new Gee.ArrayList<string> ();
        current_arg_options = new Gee.ArrayList<ArgOption?> ((el1, el2) => {
            return el1.name == el2.name && el1.value == el2.value;
        });
    }

    protected void post_set_check () throws CommonCommandError, CommandError {
        foreach (var current_option in current_options) {
            throw new CommonCommandError.UNKNOWN_OPTION (_("Unknown option '%s'").printf (current_option));
        }
        foreach (var current_arg_option in current_arg_options) {
            throw new CommonCommandError.UNKNOWN_OPTION (_("Unknown option with value '%s'").printf (
                current_arg_option.name
            ));
        }
    }
}
