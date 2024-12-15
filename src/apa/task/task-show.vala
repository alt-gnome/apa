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
    public async int show (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError, OptionsError {

        args_handler.check_args_size (1);

        var client = new AltRepo.Client ();

        foreach (string arg in args_handler.args) {
            int task_id;
            if (int.try_parse (arg, out task_id)) {
                var task_info = yield client.get_task_progress_task_info_id_async (task_id);

                print (_("Task %s:").printf (task_info.task_id.to_string ()));
                print (_("  Repo: %s").printf (task_info.task_repo));
                print (_("  Owner: %s").printf (task_info.task_owner));
                print (_("  State: %s").printf (task_info.task_state));

                foreach (var subtask in task_info.subtasks) {
                    print (_("  Subtask: %s").printf (subtask.subtask_id.to_string ()));
                    print (_("    Package name: %s").printf (subtask.src_pkg_name));
                }

            } else {
                throw new CommandError.INVALID_TASK_ID (_("Invalid task id `%s'").printf (arg));
            }
        }

        return 0;
    }
}
