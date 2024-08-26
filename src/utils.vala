/*
 * Copyright 2024 Rirusha
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

    public async int spawn_command (string[] spawn_args) {
        if (Config.IS_DEVEL) {
            print ("Run command:\n\t%s\n", string.joinv (" ", spawn_args));
        }

        int status_code = 0;

        try {
            Pid child_pid;

            Process.spawn_async_with_fds (
                null,
                spawn_args,
                null,
                SpawnFlags.SEARCH_PATH | SpawnFlags.CHILD_INHERITS_STDIN | SpawnFlags.DO_NOT_REAP_CHILD,
                null,
                out child_pid,
                -1,
                stdout.fileno (),
                stderr.fileno ()
            );

            //  // stdout:
            //  IOChannel output = new IOChannel.unix_new (stdout.fileno ());
            //  output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
            //      string line;
            //      channel.read_line (out line, null, null);
            //      print ("%s: %s", "123", line);
            //      return true;
            //  });

            ChildWatch.add (child_pid, (pid, status) => {
                status_code = Process.exit_status (status);
                Process.close_pid (pid);
                Idle.add (spawn_command.callback);
            });

        } catch (SpawnError e) {
            error (e.message);
        }

        yield;

        return status_code;
    }
}
