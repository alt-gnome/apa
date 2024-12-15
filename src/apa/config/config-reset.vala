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
    public async int reset (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var all_possible_options = Data.reset_options ();

        bool all = false;

        foreach (var option in args_handler.options) {
            var option_data = OptionEntity.find_option (all_possible_options, option);

            switch (option_data.short_option) {
                case Data.OPTION_ALL_SHORT:
                    all = true;
                    break;

                default:
                    throw new OptionsError.UNKNOWN_OPTION (option);
            }
        }

        if (all) {
            ConfigManager.get_default ().reset_all ();

        } else {
            args_handler.check_args_size ( null);

            foreach (var arg in args_handler.args) {
                ConfigManager.get_default ().reset (arg);
            }
        }

        return 0;
    }
}
