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

    int spawn_command (
        string[] spawn_args,
        Gee.ArrayList<string>? result = null
    ) {
        print_devel ("Child procces prepared:\n\t%s".printf (
            string.joinv (" ", spawn_args)
        ));

        int status_code = 0;
        SubprocessFlags flags = SEARCH_PATH_FROM_ENVP;

        if (result != null) {
            flags |= STDOUT_PIPE | STDERR_PIPE;

        } else {
            flags |= INHERIT_FDS;
        }

        try {
            var sp = new Subprocess.newv (spawn_args.copy (), flags);
            print_devel ("Child procces created");

            string? stdout_buf;
            string? stderr_buf;
            bool success = sp.communicate_utf8 (null, null, out stdout_buf, out stderr_buf);
            if (success) {
                print_devel ("Coomunicate: success");

            } else {
                print_devel ("Coomunicate: failed");
            }

            status_code = sp.get_exit_status ();

            if (stdout_buf != null) {
                result.add_all_array (stdout_buf.strip ().split ("\n"));
            }

        } catch (Error e) {
            error (e.message);
        }

        print_devel ("The child process is completed with status %i".printf (status_code));

        if (result != null) {
            print_devel ("Command result:\n\n%s".printf (string.joinv ("", result.to_array ())));
        }

        return status_code;
    }
}
