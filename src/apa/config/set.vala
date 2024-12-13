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
        args_handler.init_options (
            OptionData.concat (Data.COMMON_OPTIONS_DATA, Data.SET_OPTIONS_DATA),
            OptionData.concat (Data.COMMON_ARG_OPTIONS_DATA, Data.SET_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        if (args_handler.args.size == 0) {
            throw new CommandError.COMMON (_("Nothing to set, need key and value"));
        }

        if (args_handler.args.size == 1) {
            throw new CommandError.COMMON (_("There is no value to set"));
        }

        if (args_handler.args.size > 2) {
            throw new CommandError.TOO_MANY_ARGS (null);
        }

        var value = ConfigManager.get_default ().get_value (args_handler.args[0]);

        if (value == null) {
            throw new CommandError.COMMON (_("Unknown key, run to `apa config list' to list all posible keys"));
        }

        ConfigManager.get_default ().set_value (args_handler.args[0], args_handler.args[1]);

        return 0;
    }
}
