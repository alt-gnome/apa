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

namespace Apa {

    const string CONFIG_RESET = "reset";
    const string CONFIG_LIST = "list";
    const string CONFIG_GET = "get";
    const string CONFIG_SET = "set";

    public async int config (
        owned string[] argv,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        string? subcommand = cut_of_command (ref argv);

        var args_handler = new ArgsHandler (argv);

        switch (subcommand) {
            case CONFIG_RESET:
                check_is_root (subcommand);
                return yield Config.reset (args_handler, skip_unknown_options);

            case CONFIG_LIST:
                return yield Config.list (args_handler, skip_unknown_options);

            case CONFIG_GET:
                return yield Config.@get (args_handler, skip_unknown_options);

            case CONFIG_SET:
                check_is_root (subcommand);
                return yield Config.@set (args_handler, skip_unknown_options);

            case null:
                Help.print_config ();
                return ExitCode.BASE_ERROR;

            default:
                throw new CommandError.UNKNOWN_SUBCOMMAND (subcommand);
        }
    }
}
