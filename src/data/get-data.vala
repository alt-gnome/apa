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

namespace Apa.Get.Data {

    public const OptionData[] COMMON_OPTIONS_DATA = {
        {
            "-h", "--hide-progress",
            "-q"
        },
        {
            "-q", "--quiet",
            "-qq"
        },
        {
            "-s", "--simulate",
            "-s"
        },
        {
            "-y", "--yes",
            "-y"
        },
        {
            "-f", "--fix",
            "-f"
        },
        {
            "-V", "--version-detailed",
            "-V"
        },
    };

    public const OptionData[] COMMON_ARG_OPTIONS_DATA = {
        {
            "-o", "--option",
            "--option"
        },
        {
            "-c", "--config",
            "--config"
        },
    };

    public const OptionData[] UPDATE_OPTIONS_DATA = {};

    public const OptionData[] UPDATE_ARG_OPTIONS_DATA = {};

    public const OptionData[] UPGRADE_OPTIONS_DATA = {
        {
            "-d", "--download-only",
            "-d"
        },
        {
            "-u", "--upgraded-show",
            "-u"
        }
    };

    public const OptionData[] UPGRADE_ARG_OPTIONS_DATA = {};

    public const OptionData[] DO_OPTIONS_DATA = {
        {
            "-d", "--download-only",
            "-d"
        },
        {
            "-D", "--with-dependecies",
            "-D"
        },
        {
            "-F", "--force",
            "--reinstall"
        },
        {
            "-r", "--reinstall",
            "--reinstall"
        }
    };

    public const OptionData[] DO_ARG_OPTIONS_DATA = {};

    public const OptionData[] INSTALL_OPTIONS_DATA = {
        {
            "-d", "--download-only",
            "-d"
        },
        {
            "-F", "--force",
            "--reinstall"
        },
        {
            "-r", "--reinstall",
            "--reinstall"
        }
    };

    public const OptionData[] INSTALL_ARG_OPTIONS_DATA = {};

    public const OptionData[] REMOVE_OPTIONS_DATA = {
        {
            "-D", "--with-dependecies",
            "-D"
        }
    };

    public const OptionData[] REMOVE_ARG_OPTIONS_DATA = {};

    public const OptionData[] SOURCE_OPTIONS_DATA = {
        {
            "-b", "--build",
            "-b"
        }
    };

    public const OptionData[] SOURCE_ARG_OPTIONS_DATA = {};

    public const OptionData[] AUTOREMOVE_OPTIONS_DATA = {};

    public const OptionData[] AUTOREMOVE_ARG_OPTIONS_DATA = {};
}
