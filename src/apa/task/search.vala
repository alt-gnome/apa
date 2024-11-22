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
    public async int task_search (
        owned ArgvHandler command_handler,
        bool ignore_unknown_options = false
    ) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError {
        var client = new AltRepo.Client ();

        bool? by_package = null;
        string? owner = null;
        string? branch = null;
        var state = new Gee.ArrayList<string> ();

        foreach (var option in command_handler.options) {
            if (option == "--by-package" || option == "-p") {
                by_package = true;
            } else {
                throw new CommandError.UNKNOWN_OPTION (option);
            }
        }

        foreach (var arg_option in command_handler.arg_options) {
            if (arg_option.name == "--owner" || arg_option.name == "-o") {
                owner = arg_option.value;
            } else if (arg_option.name == "--branch" || arg_option.name == "-b") {
                branch = arg_option.value;
            } else if (arg_option.name == "--state" || arg_option.name == "-s") {
                state.add (arg_option.value);
            } else {
                throw new CommandError.UNKNOWN_ARG_OPTION (arg_option.name);
            }
        }

        var tasks_list = yield client.get_task_progress_find_tasks_async (
            command_handler.argv.to_array (),
            owner,
            branch,
            state.size == 0 ? (string[]?) null : state.to_array (),
            20,
            by_package
        );

        foreach (var task in tasks_list.tasks) {
            message (@"$(task.task_id) : $(task.task_owner)");
        }

        return 0;
    }
}
