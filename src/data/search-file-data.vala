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

    public OptionEntity?[] common_options () {
        return {
            {
                OPTION_LOCAL_SHORT, OPTION_LOCAL_LONG,
                null,
                Descriptions.option_local ()
            },
            {
                OPTION_SHORT_SHORT, OPTION_SHORT_LONG,
                null,
                Descriptions.option_short ()
            },
        };
    }

    public const string OPTION_BRANCH_SHORT = "-b";
    public const string OPTION_BRANCH_LONG = "--branch";
    public const string OPTION_ARCH_SHORT = "-a";
    public const string OPTION_ARCH_LONG = "--arch";

    public OptionEntity?[] common_arg_options () {
        return {
            {
                OPTION_BRANCH_SHORT, OPTION_BRANCH_LONG,
                null,
                Descriptions.arg_option_branch ()
            },
            {
                OPTION_BRANCH_SHORT, OPTION_BRANCH_LONG,
                null,
                Descriptions.arg_option_arch ()
            },
        };
    }
}
