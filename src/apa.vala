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

    internal const string LIST_COMMAND = "list";
    internal const string HELP_COMMAND = "help";
    internal const string VERSION_COMMAND = "version";

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
            case Get.INSTALL_COMMAND:
                return yield apa_install (ca);

            case Get.REMOVE_COMMAND:
                return yield Get.remove (ca.command_argv, ca.options);

            case Cache.SEARCH_COMMAND:
                return yield Cache.search (ca.command_argv, ca.options);

            case LIST_COMMAND:
                return yield list (ca.options);

            case VERSION_COMMAND:
                print_apa_version ();
                return 0;

            case HELP_COMMAND:
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
            if (!is_root ()) {
                print (_("Need root previlegies for this command\n"));
                return status;
            }

            if (ca.command_argv.length > 1) {
                print (_("Some packages wasn't found\n"));
            }

            string[] packages_to_install = new string[ca.command_argv.length];

            for (int arg_i = 0; arg_i < ca.command_argv.length; arg_i++) {
                var result = new Array<string> ();
                yield Cache.search (
                    { ca.command_argv[arg_i] },
                    { "--names-only" },
                    true,
                    result
                );

                string[]? possible_package_names = find_best (result.data, ca.command_argv[arg_i]);

                if (possible_package_names == null) {
                    print (_("Package '%s' wasn't found\n"), ca.command_argv[arg_i]);
                    return status;
                }

                if (possible_package_names[0] == ca.command_argv[arg_i]) {
                    packages_to_install[arg_i] = ca.command_argv[arg_i];
                    continue;
                }

                print (_("A packages with a similar name found:\n"));
                for (int i = 0; i < possible_package_names.length; i++) {
                    if (possible_package_names[i] != null) {
                        print ("\t%i) %s\n", i + 1, possible_package_names[i]);
                    }
                }

                print ("\n");

                while (true) {
                    print (_("Choose which on to install: [1 by default, 0 to exit] "));
                    var input = stdin.read_line ().strip ();

                    if (input == "") {
                        input = "1";
                    }

                    int input_int;
                    if (int.try_parse (input, out input_int)) {
                        if (input_int > 0 && input_int <= 3 && possible_package_names[input_int - 1] != null) {
                            packages_to_install[arg_i] = possible_package_names[input_int - 1];
                            break;

                        } else if (input_int == 0) {
                            return 0;
                        }
                    }
                }
            }

            return yield Get.install (packages_to_install, ca.options);
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
