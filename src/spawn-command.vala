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

    async int spawn_command (
        string[] spawn_args,
        Gee.ArrayList<string>? result = null
    ) {
        print_devel ("Child%s procces prepared:\n\t%s".printf (
            result != null ? " resulted" : "",
            string.joinv (" ", spawn_args)
        ));

        int status_code = 0;

        try {
            Pid child_pid;

            if (result != null) {
                int output;

                Process.spawn_async_with_pipes (
                    null,
                    spawn_args.copy (),
                    null,
                    SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.STDERR_TO_DEV_NULL,
                    null,
                    out child_pid,
                    null,
                    out output,
                    null
                );

                IOChannel output_channel = new IOChannel.unix_new (output);
                output_channel.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    if ((condition & IOCondition.HUP) != 0) {
                        return false;
                    }

                    string line;
                    try {
                        channel.read_line (out line, null, null);

                    } catch (Error e) {
                        error (e.message);
                    }

                    result.add (line);

                    return true;
                });

            } else {
                Process.spawn_async_with_fds (
                    null,
                    spawn_args.copy (),
                    null,
                    SpawnFlags.SEARCH_PATH | SpawnFlags.CHILD_INHERITS_STDIN | SpawnFlags.DO_NOT_REAP_CHILD,
                    null,
                    out child_pid,
                    -1,
                    stdout.fileno (),
                    stderr.fileno ()
                );
            }

            ChildWatch.add (child_pid, (pid, status) => {
                status_code = Process.exit_status (status);
                Process.close_pid (pid);
                Idle.add (spawn_command.callback);
            });

        } catch (SpawnError e) {
            error (e.message);
        }

        print_devel ("Child procces created");

        yield;

        print_devel ("The child process is completed with status %i".printf (status_code));

        if (result != null) {
            print_devel ("Command result:\n\n%s".printf (string.joinv ("", result.to_array ())));
        }

        return status_code;
    }
}
