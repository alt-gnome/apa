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

    public const OptionData[] COMMON_OPTIONS_DATA = {};

    public const OptionData[] COMMON_ARG_OPTIONS_DATA = {};

    public const OptionData[] LIST_OPTIONS_DATA = {};

    public const OptionData[] LIST_ARG_OPTIONS_DATA = {};

    public const OptionData[] SET_OPTIONS_DATA = {};

    public const OptionData[] SET_ARG_OPTIONS_DATA = {};

    public const OptionData[] GET_OPTIONS_DATA = {};

    public const OptionData[] GET_ARG_OPTIONS_DATA = {};

    public const string OPTION_ALL_SHORT = "-a";
    public const string OPTION_ALL_PACKAGE_LONG = "--all";

    public const OptionData[] RESET_OPTIONS_DATA = {
        {
            OPTION_ALL_SHORT, OPTION_ALL_PACKAGE_LONG,
            null
        },
    };

    public const OptionData[] RESET_ARG_OPTIONS_DATA = {};

    public const string AUTO_UPDATE = "auto-update";
    public const string USE_FUZZY_SEARCH = "use-fuzzy-search";

    public const DescriptionEntity[] POSSIBLE_CONFIG_KEYS = {
        { AUTO_UPDATE, Descriptions.config_auto_update },
        { USE_FUZZY_SEARCH, Descriptions.config_use_fuzzy_search },
    };
}
