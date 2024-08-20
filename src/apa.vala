/*
 * Copyright 2024 Rirusha
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Apa {

    public static int run (ref string[] argv) {
        
        var ca = CommandArgs.parse (ref argv);

        if ("-v" in ca.options || "--version" in ca.options) {
            print_version ();
        }

        if ("-h" in ca.options || "--help" in ca.options) {
            print_help ();
        }

        switch (ca.command) {
            case "install":
                Get.install (ca.command_argv, ca.options);
                return 0;

            case "remove":
                Get.remove (ca.command_argv, ca.options);
                return 0;

            case "version":
                print_version ();
                return 0;

            case "help":
                print_help ();
                return 0;

            default:
                print_help ();
                return 1;
        }
    }

    internal static void print_help () {
        print ("help!\n");
    }

    internal static void print_version () {
        print (
            "%s %s\n",
            Config.NAME,
            Config.VERSION
        );
    }
}
