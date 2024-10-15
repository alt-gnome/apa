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

    FileStream? stdout_fd;

    /**
     * If result is not `null`, then `stdout > result`
     */
    async int spawn_command_full (Gee.ArrayList<string> spawn_args,
                                  Gee.ArrayList<string>? result = null,
                                  Gee.ArrayList<string>? error_result = null,
                                  Cancellable? cancellable = null) {

        var last_sequence = new Gee.ArrayList<char> ();
        var buf = new uint8[1];

        print_devel ("Child process prepared:\n\t%s".printf (string.joinv (" ", spawn_args.to_array ())));

        Pid child_pid;
        int std_output;
        int std_error;

        int status_code = 0;

        try {
            Process.spawn_async_with_pipes_and_fds (null,
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
                                                    out std_output, out
                                                    std_error);

            print_devel ("Child process created");

            stdout_fd = FileStream.fdopen (std_output, "r");

            if (error_result != null) {
                IOChannel error_channel = new IOChannel.unix_new (std_error);
                error_channel.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    if (condition == IOCondition.HUP) {
                        return false;
                    }

                    try {
                        string line;
                        channel.read_line (out line, null, null);
                        print (line);
                        error_result.add (line);

                    } catch (Error e) {
                        error (e.message);
                    }

                    return true;
                });
            }

            ChildWatch.add (child_pid, (pid, wait_status) => {
                // Triggered when the child indicated by child_pid exits
                Process.close_pid (pid);
                status_code = Process.exit_status (wait_status);
                Idle.add (spawn_command_full.callback);
            });

            size_t read_size = 0;

            while (!cancellable.is_cancelled ()) {
                read_size = stdout_fd.read (buf);
                if (read_size == 0) {
                    break;

                } else {
                    char last_char = (char) buf[0];
                    print (last_char.to_string ());

                    if (result != null) {
                        last_sequence.add (last_char);

                        if (last_char == '\n') {
                            result.add ((string) last_sequence.to_array ());
                        }
                    }
                }

                Idle.add (spawn_command_full.callback);
                yield;
            }

        } catch (SpawnError e) {
            error (e.message);
        }

        yield;

        print_devel ("The child process is completed with status code %d".printf (status_code));

        if (result != null) {
            print_devel ("Command result:\n\n%s".printf (string.joinv ("", result.to_array ())));
        }

        return status_code;
    }

    async int spawn_command (Gee.ArrayList<string> spawn_args,
                             Gee.ArrayList<string>? error_result) {
        return yield spawn_command_full (spawn_args, null, error_result);
    }

    async int spawn_command_with_result (Gee.ArrayList<string> spawn_args,
                                         Gee.ArrayList<string> result,
                                         Gee.ArrayList<string>? error_result) {
        return yield spawn_command_full (spawn_args, result, error_result);
    }
}
