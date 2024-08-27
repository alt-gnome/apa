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

    public async int run (string[] argv) {
        
        var ca = CommandArgs.parse (argv);

        if ("-v" in ca.options || "--version" in ca.options) {
            print_apa_version ();
            return 0;
        }

        if ("-h" in ca.options || "--help" in ca.options) {
            print_help (ca.command);
            return 0;
        }

        switch (ca.command) {
            case "install":
                return yield apa_install (ca);

            case "remove":
                return yield Get.remove (ca.command_argv, ca.options);

            case "search":
                return yield Cache.search (string.joinv (" ", ca.command_argv), ca.options);

            case "version":
                print_apa_version ();
                return 0;

            case "help":
                print_apa_help ();
                return 0;

            default:
                print (_("Unknown command '%s'\n\n"), ca.command);

                print_apa_help ();
                return 1;
        }
    }

    internal async int apa_install (CommandArgs ca) {
        var status = yield Get.install (ca.command_argv, ca.options);

        if (status == 100) {
            string package_name = ca.command_argv[0];

            var result = new Array<string> ();
            yield Cache.search (
                package_name,
                {},
                true,
                result
            );

            if (result.length == 0) {
                return status;
            }

            var possible_package_name = find_best (result.data, package_name);

            print (_("A package with a similar name found:  '%s'\n"), possible_package_name);
            print (_("Do you want to install it? [Y/n] "));

            var input = stdin.read_line ().strip ();
            if (_("Y").down () == input.down () || input == "") {
                return yield Get.install ({ possible_package_name });

            } else {
                return 0;                    
            }
        }

        return status;
    }

    internal void print_help (string command) {
        if (command in Get.COMMANDS) {
            Get.print_help (command);

        } else if (command in Cache.COMMANDS) {
            Cache.print_help (command);

        } else {
            assert_not_reached ();
        }
    }

    internal void print_apa_help () {
        print ("apa help\n");
    }

    internal void print_apa_version () {
        print (
            "%s %s\n",
            Config.NAME,
            Config.VERSION
        );
    }

    public void print_devel (string str) {
        if (Config.IS_DEVEL) {
            print (
                "\n%sDEBUG\n%s%s\n\n",
                Constants.Colors.CYAN,
                str,
                Constants.Colors.ENDC
            );
        }
    }
}
