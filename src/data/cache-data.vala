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

namespace Apa.AptCache.Data {

    OptionEntity?[] common_options () {
        return {
            {
                "-p", "--package-cache",
                "-p",
                Descriptions.option_package_cache ()
            },
            {
                "-s", "--source-cache",
                "-s",
                Descriptions.option_source_cache ()
            },
            {
                "-h", "--hide-progress",
                "-q",
                Descriptions.option_hide_progress ()
            },
            {
                "-i", "--important-only",
                "-i",
                Descriptions.option_important_only ()
            },
            {
                "-r", "--recursive",
                "--recursive",
                Descriptions.option_recursive ()
            },
        };
    }

    OptionEntity?[] common_arg_options () {
        return {
            {
                "-o", "--option",
                "-o",
                Descriptions.arg_option_option ()
            },
            {
                "-c", "--config-file",
                "-c",
                Descriptions.arg_option_config_file ()
            },
        };
    }

    public const string OPTION_INSTALLED_SHORT = "-i";
    public const string OPTION_INSTALLED_LONG = "--installed";
    public const string OPTION_NAMES_ONLY_SHORT = "-n";
    public const string OPTION_NAMES_ONLY_LONG = "--names-only";

    public OptionEntity?[] search_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-n", "--names-only",
                    "-n",
                    Descriptions.option_names_only ()
                },
                {
                    "-f", "--full",
                    "-f",
                    Descriptions.option_full ()
                },
                {
                    OPTION_INSTALLED_SHORT, OPTION_INSTALLED_LONG,
                    null,
                    Descriptions.option_installed ()
                },
            }
        );
    }

    public OptionEntity?[] search_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }
}
