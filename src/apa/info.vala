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
    async int info (CommandArgs ca) {
        int status_code = Constants.ExitCode.SUCCESS;

        foreach (string package_name in ca.command_argv) {
            print (_("Info for '%s':").printf (package_name));
            status_code = yield Rpm.info (package_name, ca.options);
            if (status_code != 0) {
                return status_code;
            }

            if (package_name != ca.command_argv[ca.command_argv.length - 1]) {
                print ("");
            }
        }

        return Constants.ExitCode.SUCCESS;
    }
}
