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

    /**
     * If result is not `null`, then `stdout > result`
     */
    async int spawn_command_full (
        Gee.ArrayList<string> spawn_args,
        Gee.ArrayList<string>? result = null,
        Gee.ArrayList<string>? error = null
    ) {
        print_devel ("Child%s process prepared:\n\t%s".printf (
            result != null ? " (silence)" : "",
            string.joinv (" ", spawn_args.to_array ())
        ));

        Pid child_pid;
        int std_output;
        int std_error;

        int status_code = Constants.ExitCode.SUCCESS;

        try {
            if (result == null) {
                Process.spawn_async_with_pipes_and_fds (
                    null,
                    spawn_args.to_array ().copy (),
                    null,
                    SpawnFlags.DO_NOT_REAP_CHILD |
                    SpawnFlags.CHILD_INHERITS_STDIN |
                    SpawnFlags.SEARCH_PATH,
                    null,
                    -1,
                    stdout.fileno (),
                    -1,
                    {},
                    {},
                    out child_pid,
                    null,
                    null,
                    out std_error
                );

            } else {
                Process.spawn_async_with_pipes_and_fds (
                    null,
                    spawn_args.to_array ().copy (),
                    null,
                    SpawnFlags.DO_NOT_REAP_CHILD |
                    SpawnFlags.CHILD_INHERITS_STDIN |
                    SpawnFlags.SEARCH_PATH,
                    null,
                    -1,
                    -1,
                    -1,
                    {},
                    {},
                    out child_pid,
                    null,
                    out std_output,
                    out std_error
                );

                IOChannel output_channel = new IOChannel.unix_new (std_output);
                output_channel.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    if (condition == IOCondition.HUP) {
                        return false;
                    }

                    try {
                        string line;
                        channel.read_line (out line, null, null);

                        result.add (line);

                    } catch (Error e) {
                        print_error (e.message);
                    }

                    return true;
                });
            }

            print_devel ("Child process created");

            if (error != null) {
                IOChannel error_channel = new IOChannel.unix_new (std_error);
                error_channel.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    if (condition == IOCondition.HUP) {
                        return false;
                    }

                    try {
                        string line;
                        channel.read_line (out line, null, null);

                        error.add (line);

                    } catch (Error e) {
                        print_error (e.message);
                    }

                    return true;
                });
            }

            ChildWatch.add (child_pid, (pid, wait_status) => {
                Process.close_pid (pid);
                status_code = Process.exit_status (wait_status);
                Idle.add (spawn_command_full.callback);
            });

            //  if (!is_silence) {
            //      int c = 0;
            //      while ((c = stdout_fd.getc ()) >= 0) {
            //          print_char ((char) c);
            //          Idle.add (spawn_command_full.callback);
            //          yield;
            //      }
            //  }

        } catch (SpawnError e) {
            print_error (e.message);
        }

        yield;

        print_devel ("The child process is completed with status code %d".printf (status_code));

        if (result != null) {
            //  print_devel ("Command result:\n\n%s".printf (string.joinv ("", result.to_array ())));
        }

        return status_code;
    }

    async int spawn_command (
        Gee.ArrayList<string> spawn_args,
        Gee.ArrayList<string>? error
    ) {
        return yield spawn_command_full (spawn_args, null, error);
    }
}
