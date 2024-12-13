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

namespace Apa.Task {
    public async int search (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError, OptionsError {
        var all_possible_options = Data.SEARCH_OPTIONS_DATA;
        var all_possible_arg_options = Data.SEARCH_ARG_OPTIONS_DATA;

        args_handler.init_options (
            all_possible_options,
            all_possible_arg_options,
            skip_unknown_options
        );

        if (args_handler.args.size == 0) {
            throw new CommandError.COMMON (_("Nothing to search"));
        }

        foreach (string arg in args_handler.args) {
            if (arg.length <= 2) {
                throw new ApiBase.CommonError.ANSWER (_("The `%s' query is not suitable. The search query must be more than two characters long").printf (arg));
            }
        }

        var client = new AltRepo.Client ();

        bool? by_package = null;
        string? owner = null;
        string? branch = null;
        var state = new Gee.ArrayList<string> ();

        foreach (var option in args_handler.options) {
            var option_data = OptionData.find_option (all_possible_options, option);

            switch (option_data.short_option) {
                case Data.OPTION_BY_PACKAGE_SHORT:
                    by_package = true;
                    break;

                default:
                    assert_not_reached ();
            }
        }

        foreach (var arg_option in args_handler.arg_options) {
            var option_data = OptionData.find_option (all_possible_arg_options, arg_option.name);

            switch (option_data.short_option) {
                case Data.OPTION_OWNER_SHORT:
                    owner = arg_option.value;
                    break;

                case Data.OPTION_BRANCH_SHORT:
                    branch = arg_option.value;
                    break;

                case Data.OPTION_STATE_SHORT:
                    state.add (arg_option.value);
                    break;

                default:
                    assert_not_reached ();
            }
        }

        var tasks_list = yield client.get_task_progress_find_tasks_async (
            args_handler.args.to_array (),
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
            print (_("  Subtasks: "), false);

            var subtasks_array = new Gee.ArrayList<string> ();
            foreach (var subtask in task.subtasks) {
                if (subtask.subtask_srpm_name != "") {
                    subtasks_array.add ("%s-%s".printf (subtask.subtask_srpm_name, subtask.subtask_tag_name));

                } else if (subtask.subtask_package != "") {
                    subtasks_array.add ("%s-%s".printf (subtask.subtask_package, subtask.subtask_tag_name));

                } else if (subtask.subtask_pkg_from != "") {
                    subtasks_array.add ("%s-%s".printf (subtask.subtask_pkg_from, subtask.subtask_tag_name));

                } else {
                    subtasks_array.clear ();
                    var task_info = yield client.get_task_progress_task_info_id_async (task.task_id);
                    foreach (var sbtsk in task_info.subtasks) {
                        subtasks_array.add ("%s-%s".printf (sbtsk.src_pkg_name, sbtsk.subtask_tag_name));
                    }
                    break;
                }
            }
            print (string.joinv (", ", subtasks_array.to_array ()));
        }

        return 0;
    }
}
