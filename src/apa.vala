/*
 * Copyright 2024 Vladimir Vaskov
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
    internal const string INFO_COMMAND = "info";
    internal const string HELP_COMMAND = "help";
    internal const string VERSION_COMMAND = "version";

    public async int run (string[] argv) {

        var ca = CommandArgs.parse (argv);

        if ("-h" in ca.options || "--help" in ca.options) {
            print_help (ca.command);
            return 0;
        }

        if ("-v" in ca.options || "--version" in ca.options) {
            print_apa_version ();
            return 0;
        }

        switch (ca.command) {
            case Get.INSTALL:
                check_is_root (ca.command);
                check_internet_connection ();
                return yield apa_install (ca);

            case Get.REMOVE:
                check_is_root (ca.command);
                return yield Get.remove (ca.command_argv, ca.options);

            case Get.UPDATE:
                check_is_root (ca.command);
                check_internet_connection ();
                return yield Get.update ();

            case Cache.SEARCH:
                check_internet_connection ();
                return yield Cache.search (ca.command_argv, ca.options);

            case LIST_COMMAND:
                return yield Rpm.list (ca.options);

            case INFO_COMMAND:
                return yield apa_info (ca);

            case VERSION_COMMAND:
                print_apa_version ();
                return 0;

            case HELP_COMMAND:
                print_apa_help ();
                return 0;

            case null:
                print_apa_help ();
                return 1;

            default:
                print (_("Unknown command '%s'").printf (ca.command));

                print_apa_help ();
                return 1;
        }
    }

    internal async int apa_install (CommandArgs ca) {
        var error = new Gee.ArrayList<string> ();
        var status = yield Get.install (ca.command_argv, ca.options, error);

        if (status == 100) {
            string error_message = "";

            if (error.size > 0) {
                error_message = error[0];
            }

            try {
                string couldnt_find_packages_translated_pattern = (dgettext (
                    "apt",
                    "Couldn't find package %s"
                )).replace ("%s", ".*");

                var regex = new Regex (
                    couldnt_find_packages_translated_pattern,
                    RegexCompileFlags.OPTIMIZE,
                    RegexMatchFlags.NOTEMPTY
                );

                if (regex.match (error_message, 0, null)) {
                    print (_("Some packages wasn't found"));
                    return status;
                }

            } catch (Error e) {
                print_error (e.message);
                return 1;
            }

            foreach (string a in error) {
                print_devel (a);
                return status;
            }

            string[] packages_to_install = new string[ca.command_argv.length];

            for (int arg_i = 0; arg_i < ca.command_argv.length; arg_i++) {
                char[] package_chars = (char[]) ca.command_argv[arg_i].data;
                string[] char_string = new string[ca.command_argv[arg_i].length];

                for (int i = 0; i < ca.command_argv[arg_i].length; i++) {
                    char_string[i] = package_chars[i].to_string ();
                }

                var result = new Gee.ArrayList<string> ();
                yield Cache.search (
                    { string.joinv (".*", char_string) },
                    { "--names-only" },
                    result
                );

                do_short_array_list (ref result);

                string[]? possible_package_names = fuzzy_search (ca.command_argv[arg_i], result.to_array ());

                if (possible_package_names == null) {
                    print (_("Package '%s' not found").printf (ca.command_argv[arg_i]));
                    return status;
                }

                if (possible_package_names[0] == ca.command_argv[arg_i]) {
                    packages_to_install[arg_i] = ca.command_argv[arg_i];
                    continue;
                }

                print (_("A packages with a similar name found:"));
                for (int i = 0; i < possible_package_names.length; i++) {
                    if (possible_package_names[i] != null) {
                        print ("\t%i) %s".printf (i + 1, possible_package_names[i]));
                    }
                }

                print ("");

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

    internal async int apa_info (CommandArgs ca) {
        int status_code = 0;

        foreach (string package_name in ca.command_argv) {
            print (_("Info for '%s':").printf (package_name));
            status_code = yield Rpm.info (package_name, ca.options);
            if (status_code != 0) {
                return status_code;
            }

            if (package_name != ca.command_argv[ca.command_argv.length - 1]) {
                print ("");
            }
        }

        return 0;
    }

    internal void print_help (string? command) {
        if (command in Get.COMMANDS) {
            Get.print_help (command);

        } else if (command in Cache.COMMANDS) {
            Cache.print_help (command);

        } else if (command == null) {
            print_apa_help ();

        } else {
            print (_("Unknown command '%s'").printf (command));
            print (_("Try `apa --help` to see all commands"));
        }
    }

    internal void print_apa_help () {
        print ("apa help");
    }

    internal void print_apa_version () {
        print ("%s %s".printf (
            Config.NAME,
            Config.VERSION
        ));
    }

    public void check_is_root (string command) {
        if (is_root ()) {
            return;
        }

        print (_("Need root previlegies for '%s' command").printf (command));
        print (_("Aborting."));
        Process.exit (100);
    }

    public void check_internet_connection () {
        if (!Config.EXPERIMENTAL_CHECK_IC) {
            return;
        }

        if (has_internet_connection ()) {
            return;
        }

        print (_("No internet connection"));
        print (_("Aborting."));
        Process.exit (100);
    }
}
