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
        if (command_handler.argv.size < 1) {
            throw new CommandError.NO_PACKAGES (_("Nothing to search"));
        }

        foreach (string arg in command_handler.argv) {
            if (arg.length <= 2) {
                throw new ApiBase.CommonError.ANSWER (_("The `%s' query is not suitable. The search query must be more than two characters long").printf (arg));
            }
        }

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
            11,
            by_package
        );

        if (tasks_list.tasks.size > 10) {
            print (_("Too many tasks, showing only the first 10"));
        }

        for (int i = 0; i < 10 && i < tasks_list.tasks.size; i++) {
            var task = tasks_list.tasks[i];

            print (_("Task %s:").printf (task.task_id.to_string ()));
            print (_("  Repo: %s").printf (task.task_repo));
            print (_("  Owner: %s").printf (task.task_owner));
            print (_("  State: %s").printf (task.task_state));
            print (_("  Has %d subtasks").printf (task.subtasks.size));
        }

        return 0;
    }
}
