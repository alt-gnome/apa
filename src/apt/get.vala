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

namespace Apa.Get {

    const string ORIGIN = "apt-get";

    public const string UPDATE = "update";
    public const string UPGRADE = "upgrade";
    public const string DO = "do";
    public const string INSTALL = "install";
    public const string REINSTALL = "reinstall";
    public const string REMOVE = "remove";
    public const string SOURCE = "source";
    public const string AUTOREMOVE = "autoremove";

    public static async int update (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, UPDATE);

        command.fill_by_args_handler (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.UPDATE_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.UPDATE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int upgrade (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, "dist-upgrade");

        command.fill_by_args_handler (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.UPGRADE_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.UPGRADE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int @do (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, INSTALL);

        command.fill_by_args_handler_with_args (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.DO_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.DO_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int install (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        Gee.ArrayList<string>? result = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, INSTALL);

        command.fill_by_args_handler_with_args (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.INSTALL_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.INSTALL_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command_full (command.spawn_vector, result, error);
    }

    public static async int remove (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, REMOVE);

        command.fill_by_args_handler_with_args (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.REMOVE_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.REMOVE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int source (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, SOURCE);

        command.fill_by_args_handler_with_args (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.SOURCE_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.SOURCE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int autoremove (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, AUTOREMOVE);

        command.fill_by_args_handler (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Get.Data.AUTOREMOVE_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Get.Data.AUTOREMOVE_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }
}
