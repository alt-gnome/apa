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

namespace Apa.Config {
    public async int list (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws OptionsError {
        foreach (var possible_key in Data.possible_config_keys ()) {
            print ("%s%s: %s".printf (
                Help.indx (1),
                possible_key.name,
                ConfigManager.get_default ().get_value (possible_key.name)
            ));
            print ("%s%s".printf (
                Help.indx (2),
                possible_key.description
            ));
            print ("%s%s %s".printf (
                Help.indx (2),
                _("Default value:"),
                possible_key.default_value
            ));
        }

        return 0;
    }
}
