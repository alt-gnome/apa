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

namespace Apa.SearchFile.Data {

    public const string OPTION_LOCAL_SHORT = "-l";
    public const string OPTION_LOCAL_LONG = "--local";
    public const string OPTION_SHORT_SHORT = "-s";
    public const string OPTION_SHORT_LONG = "--short";

    public const OptionData[] COMMON_OPTIONS_DATA = {
        {
            OPTION_LOCAL_SHORT, OPTION_LOCAL_LONG,
            null
        },
        {
            OPTION_SHORT_SHORT, OPTION_SHORT_LONG,
            null
        },
    };

    public const string OPTION_BRANCH_SHORT = "-b";
    public const string OPTION_BRANCH_LONG = "--branch";
    public const string OPTION_ARCH_SHORT = "-a";
    public const string OPTION_ARCH_LONG = "--arch";

    public const OptionData[] COMMON_ARG_OPTIONS_DATA = {
        {
            OPTION_BRANCH_SHORT, OPTION_BRANCH_LONG,
            null
        },
        {
            OPTION_BRANCH_SHORT, OPTION_BRANCH_LONG,
            null
        },
    };
}
