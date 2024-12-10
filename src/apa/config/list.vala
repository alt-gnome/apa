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
        args_handler.init_options (
            OptionData.concat (Data.COMMON_OPTIONS_DATA, Data.LIST_OPTIONS_DATA),
            OptionData.concat (Data.COMMON_ARG_OPTIONS_DATA, Data.LIST_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        foreach (var possible_key in Data.POSSIBLE_CONFIG_KEYS) {
            print ("%s\t- %s".printf (possible_key.name, possible_key.description_getter ()));
        }

        return 0;
    }
}
