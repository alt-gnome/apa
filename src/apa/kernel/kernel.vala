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

    const string KERNEL_UPGRADE_SUBCOMMAND = "upgrade";
    const string KERNEL_LIST_SUBCOMMAND = "list";

    public async int kernel (
        owned string[] argv,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        string? subcommand = cut_of_command (ref argv);

        var args_handler = new ArgsHandler (argv);

        switch (subcommand) {
            case KERNEL_UPGRADE_SUBCOMMAND:
                check_pk_is_not_running ();
                check_is_root (subcommand);
                return yield kernel_upgrade (args_handler, skip_unknown_options);

            case KERNEL_LIST_SUBCOMMAND:
                return yield kernel_list (args_handler, skip_unknown_options);

            case null:
                Help.print_kernel ();
                return ExitCode.BASE_ERROR;

            default:
                print_error (_("Unknown subcommand `%s'").printf (subcommand));
                return ExitCode.BASE_ERROR;
        }
    }
}
