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

namespace Apa.Cache.Data {

    public const OptionData[] COMMON_OPTIONS_DATA = {
        {
            "-p", "--package-cache",
            "-p",
            Descriptions.option_package_cache
        },
        {
            "-s", "--source-cache",
            "-s",
            Descriptions.option_source_cache
        },
        {
            "-h", "--hide-progress",
            "-q",
            Descriptions.option_hide_progress
        },
        {
            "-i", "--important-only",
            "-i",
            Descriptions.option_important_only
        }
    };

    public const OptionData[] COMMON_ARG_OPTIONS_DATA = {
        {
            "-o", "--option",
            "--option",
            Descriptions.arg_option_option
        },
        {
            "-c", "--config",
            "-c",
            Descriptions.arg_option_config
        }
    };

    public const OptionData[] SEARCH_OPTIONS_DATA = {};

    public const OptionData[] SEARCH_ARG_OPTIONS_DATA = {};
}
