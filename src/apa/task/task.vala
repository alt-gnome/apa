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
    const string TASK_INSTALL_SUBCOMMAND = "install";
    const string TASK_LIST_SUBCOMMAND = "list";

    public async int task (
        owned string[] argv,
        bool skip_unknown_options = false
    ) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError, OptionsError {
        string? subcommand = cut_of_command (ref argv);

        var args_handler = new ArgsHandler (argv);

        switch (subcommand) {
            case TASK_SEARCH_SUBCOMMAND:
                return yield Task.search (args_handler, skip_unknown_options);

            case TASK_SHOW_SUBCOMMAND:
                return yield Task.show (args_handler, skip_unknown_options);

            case TASK_INSTALL_SUBCOMMAND:
                check_pk_is_not_running ();
                check_is_root (subcommand);
                return yield Task.install (args_handler, skip_unknown_options);

            case TASK_LIST_SUBCOMMAND:
                return yield Task.list (args_handler, skip_unknown_options);

            case null:
                Help.print_task ();
                return ExitCode.BASE_ERROR;

            default:
                throw new CommandError.UNKNOWN_SUBCOMMAND (subcommand);
        }
    }
}
