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

namespace Apa.Help {

    public const string APA =
_("""APA - ALT Packages Assistant. Your best friend in this cruel world of many package tools.

Usage: 
        apa <command> ..

Commands:

""");

    public const string INSTALL =
"""Usage: 
        apa install [OPTIONS[=VALUE]] <package1> <package2> ..

Options:

    -h, --hide-progress
    -q, --quiet
    -s, --simulate
    -y, --yes
    -f, --fix
    -V, --version-detailed
    -d, --download-only
    -b, --build
    -o=?, --option=?

""";
}
