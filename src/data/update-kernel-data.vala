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

 namespace Apa.UpdateKernel.Data {

    public const OptionData[] COMMON_OPTIONS_DATA = {};

    public const OptionData[] COMMON_ARG_OPTIONS_DATA = {};

    public const OptionData[] UPDATE_OPTIONS_DATA = {
        {
            "-F", "--force",
            "-f"
        },
        {
            "-d", "--download-only",
            "-d"
        },
        {
            "-s", "--simulate",
            "-n"
        },
        {
            "-H", "--header",
            "-H"
        },
        {
            "-l", "--list",
            "-l"
        },
        {
            "-a", "--all",
            "-a"
        },
        {
            "-i", "--interactive",
            "-i"
        },
        {
            "-d", "--debuginfo",
            "-d"
        }
    };

    public const OptionData[] UPDATE_ARG_OPTIONS_DATA = {
        {
            "-A", "--add-module",
            "-A"
        },
        {
            "-D", "--del-module",
            "-D"
        },
        {
            "-t", "--type",
            "-t"
        },
        {
            "-r", "--release",
            "-r"
        }
    };

    public const OptionData[] LIST_OPTIONS_DATA = {
        {
            "-a", "--all",
            "-a"
        }
    };

    public const OptionData[] LIST_ARG_OPTIONS_DATA = {};
}
