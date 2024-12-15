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

namespace Apa.Config.Data {

    OptionEntity?[] common_options () {
        return {};
    }

    OptionEntity?[] common_arg_options () {
        return {};
    }

    public OptionEntity?[] list_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] list_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] set_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] set_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] get_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] get_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public const string OPTION_ALL_SHORT = "-a";
    public const string OPTION_ALL_PACKAGE_LONG = "--all";

    public OptionEntity?[] reset_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    OPTION_ALL_SHORT, OPTION_ALL_PACKAGE_LONG,
                    null,
                    Descriptions.option_all ()
                },
            }
        );
    }

    public OptionEntity?[] reset_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public const string AUTO_UPDATE = "auto-update";
    public const string USE_FUZZY_SEARCH = "use-fuzzy-search";
    public const string AUTO_UPGRADE_KERNEL = "auto-upgrade-kernel";

    public ConfigEntity[] possible_config_keys () {
        return {
            { AUTO_UPDATE, Descriptions.config_auto_update (), "([Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee])", "true" },
            { USE_FUZZY_SEARCH, Descriptions.config_use_fuzzy_search (), "([Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee])", "true" },
            { AUTO_UPGRADE_KERNEL, Descriptions.config_auto_upgrade_kernel (), "([Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee])", "false" },
        };
    }
}
