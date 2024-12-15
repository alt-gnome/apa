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

namespace Apa.AptCache {

    const string ORIGIN = "apt-cache";

    public const string SEARCH = "search";

    public static async int search_all (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null
    ) throws OptionsError {
        return yield search (
            new ArgsHandler.with_data (
                args_handler.options.to_array (),
                args_handler.arg_options.to_array (),
                { ".*" }
            ),
            result,
            error
        );
    }

    public static async int search (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, SEARCH);

        command.fill_by_args_handler_with_args (
            args_handler,
            AptCache.Data.search_options (),
            AptCache.Data.search_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command_full (command.spawn_vector, result, error);
    }
}
