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

    private static bool process_line (IOChannel channel, IOCondition condition) {
        try {
            string line;
            channel.read_line (out line, null, null);
            if (line == null) {
                return false;
            }
            print (line);

        } catch (Error e) {
            print ("Error: %s\n", e.message);
            return false;
        }

        return true;
    }

    public static void spawn_command (string[] spawn_args) {
        MainLoop loop = new MainLoop ();

        try {
            Pid child_pid;
            int standard_input;
            int standard_output;
            int standard_error;

            Process.spawn_async_with_pipes (
                null,
                spawn_args,
                null,
                SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.CHILD_INHERITS_STDIN,
                null,
                out child_pid,
                out standard_input,
                out standard_output,
                out standard_error
            );

            IOChannel output = new IOChannel.unix_new (standard_output);
            output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                return process_line (channel, condition);
            });

            IOChannel error = new IOChannel.unix_new (standard_error);
            error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                return process_line (channel, condition);
            });

            ChildWatch.add (child_pid, (pid, status) => {
                Process.close_pid (pid);
                loop.quit ();
            });

            loop.run ();
        } catch (SpawnError e) {
            print ("Error: %s\n", e.message);
        }
    }
}
