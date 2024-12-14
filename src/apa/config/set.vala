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
    public async int @set (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        if (args_handler.args.size == 0) {
            throw new CommandError.COMMON (_("Nothing to set, need key and value"));
        }

        foreach (var pair in args_handler.args) {
            var parts = pair.split ("=");
            if (parts.length != 2) {
                throw new CommandError.COMMON (_("Invalid key-value pair, need key and value"));

            } else if (parts[1].length == 0) {
                throw new CommandError.COMMON (_("Invalid value, value cannot be empty"));
            }

            var key = parts[0];
            var value = parts[1];

            var config_entity = ConfigEntity.find (Data.possible_config_keys (), key);

            if (!ConfigManager.get_default ().has_key (key) || config_entity == null) {
                throw new CommandError.COMMON (_("Unknown key, run to `apa config list' to list all posible keys"));
            }

            if (!Regex.match_simple (config_entity.possible_values_pattern, value.down (), RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY)) {
                throw new CommandError.COMMON (_("Invalid value. Try `apa config list' to see possible values"));
            }
        }

        foreach (var pair in args_handler.args) {
            var parts = pair.split ("=");

            var key = parts[0];
            var value = parts[1];

            ConfigManager.get_default ().set_value (key, value);
        }

        return 0;
    }
}
