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

namespace Apa.Repo {

    const string ORIGIN = "apt-repo";

    public const string REPO_LIST = "repo-list";
    public const string TEST = "test";

    public static async int test (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, TEST);

        command.fill_by_args_handler_with_args (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Repo.Data.TEST_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Repo.Data.TEST_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }

    public static async int repo_list (
        ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) throws OptionsError {
        var command = new Command (ORIGIN, "list");

        command.fill_by_args_handler (
            args_handler,
            OptionData.concat (Get.Data.COMMON_OPTIONS_DATA, Repo.Data.REPO_LIST_OPTIONS_DATA),
            OptionData.concat (Get.Data.COMMON_ARG_OPTIONS_DATA, Repo.Data.REPO_LIST_ARG_OPTIONS_DATA),
            skip_unknown_options
        );

        return yield spawn_command (command.spawn_vector, error);
    }
}
