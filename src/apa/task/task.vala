/*
 * Copyright 2024 Vladimir Vaskov
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

namespace Apa {

    const string TASK_SEARCH_SUBCOMMAND = "search";
    const string TASK_SHOW_SUBCOMMAND = "show";

    public async int task (
        owned SubCommandHandler command_handler,
        bool ignore_unknown_options = false
    ) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError {
        switch (command_handler.subcommand) {
            case TASK_SEARCH_SUBCOMMAND:
                return yield task_search (command_handler, ignore_unknown_options);

            case TASK_SHOW_SUBCOMMAND:
                return yield task_show (command_handler, ignore_unknown_options);

            case null:
                Help.print_task ();
                return Constants.ExitCode.BASE_ERROR;

            default:
                print_error (_("Unknown subcommand `%s'").printf (command_handler.subcommand));
                return Constants.ExitCode.BASE_ERROR;
        }
    }
}
