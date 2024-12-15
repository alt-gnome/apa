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

namespace Apa.AptRepo {

    const string ORIGIN = "apt-repo";

    public const string LIST = "list";
    public const string TEST = "test";
    public const string ADD = "add";
    public const string RM = "rm";

    public static async int test (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, TEST);

        command.fill_by_args_handler_with_args (
            args_handler,
            AptRepo.Data.test_options (),
            AptRepo.Data.test_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int list (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, LIST);

        command.fill_by_args_handler (
            args_handler,
            AptRepo.Data.list_options (),
            AptRepo.Data.list_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int add (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, ADD);

        command.fill_by_args_handler_with_args (
            args_handler,
            AptRepo.Data.add_options (),
            AptRepo.Data.add_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int rm (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, RM);

        command.fill_by_args_handler_with_args (
            args_handler,
            AptRepo.Data.rm_options (),
            AptRepo.Data.rm_arg_options (),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }
}
