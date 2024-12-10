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

namespace Apa.Repo.Data {

    public const OptionData[] COMMON_OPTIONS_DATA = {
        {
            "-s", "--simulate",
            "--dry-run"
        },
        {
            "-h", "--hsh-apt-config",
            "--hsh-apt-config"
        },
    };

    public const OptionData[] COMMON_ARG_OPTIONS_DATA = {};

    public const OptionData[] TEST_OPTIONS_DATA = {};

    public const OptionData[] TEST_ARG_OPTIONS_DATA = {};

    public const OptionData[] REPO_LIST_OPTIONS_DATA = {
        {
            "-a", "--all",
            "-a"
        }
    };

    public const OptionData[] REPO_LIST_ARG_OPTIONS_DATA = {};
}
