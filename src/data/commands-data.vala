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

namespace Apa.Commands.Data {

    public const string CONFIG_COMMAND = "config";
    public const string KERNEL_COMMAND = "kernel";
    public const string LIST_COMMAND = "list";
    public const string INFO_COMMAND = "info";
    public const string MOO_COMMAND = "moo";
    public const string TASK_COMMAND = "task";
    public const string HELP_COMMAND = "help";
    public const string VERSION_COMMAND = "version";
    public const string SEARCH_FILE_COMMAND = "search-file";
    public const string REPO_COMMAND = "repo";
    public const string REINSTALL_COMMAND = "reinstall";

    public const string KERNEL_UPGRADE_SUBCOMMAND = "upgrade";
    public const string KERNEL_LIST_SUBCOMMAND = "list";

    public const string TASK_ADD_SUBCOMMAND = "add";
    public const string TASK_SEARCH_SUBCOMMAND = "search";
    public const string TASK_SHOW_SUBCOMMAND = "show";
    public const string TASK_INSTALL_SUBCOMMAND = "install";
    public const string TASK_LIST_SUBCOMMAND = "list";

    public const string REPO_LIST_SUBCOMMAND = "list";
    public const string REPO_ADD_SUBCOMMAND = "add";
    public const string ADD_AIDES_SUBCOMMAND = "add-aides";
    public const string REMOVE_AIDES_SUBCOMMAND = "remove-aides";
    public const string REPO_REMOVE_SUBCOMMAND = "remove";

    public const string CONFIG_RESET_SUBCOMMAND = "reset";
    public const string CONFIG_LIST_SUBCOMMAND = "list";
    public const string CONFIG_GET_SUBCOMMAND = "get";
    public const string CONFIG_SET_SUBCOMMAND = "set";

    public const string[] HIDED_COMMANDS = {
        MOO_COMMAND,
        AptGet.SOURCE,
    };

    public CommandEntity[] all_commands () {
        return {
            new CommandEntity (
                MOO_COMMAND,
                Descriptions.moo (),
                {},
                {},
                false, false
            ),
            new CommandEntity (
                AptGet.INSTALL,
                Descriptions.install (),
                AptGet.Data.install_options (),
                AptGet.Data.install_arg_options (),
                true, true
            ),
            new CommandEntity (
                REINSTALL_COMMAND,
                Descriptions.reinstall (),
                AptGet.Data.install_options (),
                AptGet.Data.install_arg_options (),
                true, true
            ),
            new CommandEntity (
                AptGet.REMOVE,
                Descriptions.remove (),
                AptGet.Data.remove_options (),
                AptGet.Data.remove_arg_options (),
                true, true
            ),
            new CommandEntity (
                AptGet.DO,
                Descriptions.do (),
                AptGet.Data.do_options (),
                AptGet.Data.do_arg_options (),
                true, true
            ),
            new CommandEntity (
                AptGet.UPDATE,
                Descriptions.update (),
                AptGet.Data.update_options (),
                AptGet.Data.update_arg_options (),
                true, true
            ),
            new CommandEntity (
                AptGet.UPGRADE,
                Descriptions.upgrade (),
                AptGet.Data.upgrade_options (),
                AptGet.Data.upgrade_arg_options (),
                true, true
            ),
            new CommandEntity (
                AptCache.SEARCH,
                Descriptions.search (),
                AptCache.Data.search_options (),
                AptCache.Data.search_arg_options (),
                false, false
            ),
            new CommandEntity.root (
                KERNEL_COMMAND,
                Descriptions.kernel (),
                kernel_subcommands ()
            ),
            new CommandEntity.root (
                CONFIG_COMMAND,
                Descriptions.config (),
                config_subcommands ()
            ),
            new CommandEntity.root (
                TASK_COMMAND,
                Descriptions.task (),
                task_subcommands ()
            ),
            new CommandEntity.root (
                REPO_COMMAND,
                Descriptions.repo (),
                repo_subcommands ()
            ),
            new CommandEntity (
                AptGet.AUTOREMOVE,
                Descriptions.autoremove (),
                AptGet.Data.autoremove_options (),
                AptGet.Data.autoremove_arg_options (),
                true, true
            ),
            new CommandEntity (
                AptGet.SOURCE,
                Descriptions.source (),
                AptGet.Data.source_options (),
                AptGet.Data.source_arg_options (),
                true, true
            ),
            new CommandEntity (
                LIST_COMMAND,
                Descriptions.list (),
                Rpm.Data.list_options (),
                Rpm.Data.list_arg_options (),
                false, false
            ),
            new CommandEntity (
                INFO_COMMAND,
                Descriptions.info (),
                Rpm.Data.info_options (),
                Rpm.Data.info_arg_options (),
                false, false
            ),
            new CommandEntity (
                SEARCH_FILE_COMMAND,
                Descriptions.search_file (),
                SearchFile.Data.common_options (),
                SearchFile.Data.common_arg_options (),
                false, false
            ),
            new CommandEntity (
                HELP_COMMAND,
                Descriptions.help (),
                {},
                {},
                false, false
            ),
            new CommandEntity (
                VERSION_COMMAND,
                Descriptions.version (),
                {},
                {},
                false, false
            ),
        };
    }

    public CommandEntity[] kernel_subcommands () {
        return {
            new CommandEntity (
                KERNEL_UPGRADE_SUBCOMMAND,
                Descriptions.kernel_upgrade (),
                UpdateKernel.Data.update_options (),
                UpdateKernel.Data.update_arg_options (),
                true, true
            ),
            new CommandEntity (
                KERNEL_LIST_SUBCOMMAND,
                Descriptions.kernel_list (),
                UpdateKernel.Data.list_options (),
                UpdateKernel.Data.list_arg_options (),
                false, false
            ),
        };
    }

    public CommandEntity[] config_subcommands () {
        return {
            new CommandEntity (
                CONFIG_RESET_SUBCOMMAND,
                Descriptions.config_reset (),
                Config.Data.reset_options (),
                Config.Data.reset_arg_options (),
                true, false
            ),
            new CommandEntity (
                CONFIG_LIST_SUBCOMMAND,
                Descriptions.config_list (),
                Config.Data.list_options (),
                Config.Data.list_arg_options (),
                false, false
            ),
            new CommandEntity (
                CONFIG_GET_SUBCOMMAND,
                Descriptions.config_get (),
                Config.Data.get_options (),
                Config.Data.get_arg_options (),
                false, false
            ),
            new CommandEntity (
                CONFIG_SET_SUBCOMMAND,
                Descriptions.config_set (),
                Config.Data.set_options (),
                Config.Data.set_arg_options (),
                true, false
            ),
        };
    }

    public CommandEntity[] task_subcommands () {
        return {
            new CommandEntity (
                TASK_ADD_SUBCOMMAND,
                Descriptions.task_add (),
                AptRepo.Data.add_options (),
                AptRepo.Data.add_arg_options (),
                true, false
            ),
            new CommandEntity (
                TASK_SEARCH_SUBCOMMAND,
                Descriptions.task_search (),
                Task.Data.search_options (),
                Task.Data.search_arg_options (),
                false, false
            ),
            new CommandEntity (
                TASK_SHOW_SUBCOMMAND,
                Descriptions.task_show (),
                Task.Data.show_options (),
                Task.Data.show_arg_options (),
                false, false
            ),
            new CommandEntity (
                TASK_INSTALL_SUBCOMMAND,
                Descriptions.task_install (),
                AptRepo.Data.test_options (),
                AptRepo.Data.test_arg_options (),
                true, true
            ),
            new CommandEntity (
                TASK_LIST_SUBCOMMAND,
                Descriptions.task_list (),
                AptRepo.Data.list_options (),
                AptRepo.Data.list_arg_options (),
                false, false
            ),
        };
    }

    public CommandEntity[] repo_subcommands () {
        return {
            new CommandEntity (
                REPO_LIST_SUBCOMMAND,
                Descriptions.repo_list (),
                AptRepo.Data.list_options (),
                AptRepo.Data.list_arg_options (),
                false, false
            ),
            new CommandEntity (
                REPO_ADD_SUBCOMMAND,
                Descriptions.repo_add (),
                AptRepo.Data.add_options (),
                AptRepo.Data.add_arg_options (),
                true, false
            ),
            new CommandEntity (
                ADD_AIDES_SUBCOMMAND,
                Descriptions.repo_add_aides (),
                AptRepo.Data.add_options (),
                AptRepo.Data.add_arg_options (),
                true, false
            ),
            new CommandEntity (
                REPO_REMOVE_SUBCOMMAND,
                Descriptions.repo_remove (),
                AptRepo.Data.rm_options (),
                AptRepo.Data.rm_arg_options (),
                true, false
            ),
            new CommandEntity (
                REMOVE_AIDES_SUBCOMMAND,
                Descriptions.repo_remove_aides (),
                AptRepo.Data.rm_options (),
                AptRepo.Data.rm_arg_options (),
                true, false
            ),
        };
    }
}
