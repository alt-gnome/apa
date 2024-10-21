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

    void print_help (string? command) {
        switch (command) {
            case Get.INSTALL:
                print (INSTALL, false);
                return;

            case Get.REMOVE:
                print (REMOVE, false);
                return;

            case Get.UPDATE:
                print (UPDATE, false);
                return;

            case Cache.SEARCH:
                assert_not_reached ();

            case Apa.LIST_COMMAND:
                assert_not_reached ();

            case Apa.INFO_COMMAND:
                assert_not_reached ();

            case Apa.MOO_COMMAND:
                print (MOO, false);
                return;

            case Apa.VERSION_COMMAND:
                print (VERSION, false);
                return;

            case Apa.HELP_COMMAND:
                print (APA, false);
                return;

            case null:
                print (APA, false);
                return;

            default:
                print_error (_("Unknown command '%s'").printf (command));
                print (Help.APA, false);
                return;
        }
    }

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

public const string REMOVE =
"""Usage: 
        apa remove [OPTIONS[=VALUE]] <package1> <package2> ..

Options:

""";

public const string UPDATE =
"""Usage: 
        apa update [OPTIONS[=VALUE]]

Options:

""";

public const string MOO =
"""Mooage: 
        apa moo [PHRASE]

""";

public const string VERSION =
"""Usage: 
        apa version

    Equal to:
        apa --version

""";
}
