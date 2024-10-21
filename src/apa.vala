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
    internal const string MOO_COMMAND = "moo";
    internal const string HELP_COMMAND = "help";
    internal const string VERSION_COMMAND = "version";

    public async int run (string[] argv) {

        var ca = CommandArgs.parse (argv);

        if ("-h" in ca.options || "--help" in ca.options) {
            Help.print_help (ca.command);
            return Constants.ExitCode.SUCCESS;
        }

        if ("-v" in ca.options || "--version" in ca.options) {
            print (get_version ());
            return Constants.ExitCode.SUCCESS;
        }

        try {
            switch (ca.command) {
                case Get.INSTALL:
                    check_is_root (ca.command);
                    return yield install (ca);

                case Get.REMOVE:
                    check_is_root (ca.command);
                    return yield Get.remove (ca.command_argv, ca.options);

                case Get.UPDATE:
                    check_is_root (ca.command);
                    return yield Get.update ();

                case Cache.SEARCH:
                    return yield Cache.search (ca.command_argv, ca.options);

                case LIST_COMMAND:
                    return yield Rpm.list (ca.options);

                case INFO_COMMAND:
                    return yield info (ca);

                case MOO_COMMAND:
                    return apa_moo (ca);

                case VERSION_COMMAND:
                    print (get_version ());
                    return Constants.ExitCode.SUCCESS;

                case HELP_COMMAND:
                    print (Help.APA, false);
                    return Constants.ExitCode.SUCCESS;

                case null:
                    print (Help.APA, false);
                    return Constants.ExitCode.BASE_ERROR;

                default:
                    print_error (_("Unknown command '%s'").printf (ca.command));
                    print (Help.APA, false);
                    return Constants.ExitCode.BASE_ERROR;
            }

        } catch (Error e) {
            print_error (e.message);
            return Constants.ExitCode.BASE_ERROR;
        }
    }

    internal async int install (owned CommandArgs ca) throws CommonCommandError, CommandError {
        while (true) {
            var error = new Gee.ArrayList<string> ();
            var status = yield Get.install (ca.command_argv, ca.options, ca.arg_options, error);

            if (status != Constants.ExitCode.SUCCESS && error.size > 0) {

                string error_message = normalize_error (error);
                string? package;

                switch (detect_error (error_message, out package)) {
                    case ErrorType.COULDNT_FIND_PACKAGE:
                        print (_("Some packages not found"));

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

                            print (_("A packages with a similar name were found:"));
                            var answer = give_choice (possible_package_names);

                            if (answer != null) {
                                packages_to_install[arg_i] = answer;

                            } else {
                                return status;
                            }
                        }

                        ca.command_argv = packages_to_install;
                        break;

                    case ErrorType.PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS:
                        error_message = error_message[0:error_message.length - 2] + ":";
                        print (error_message);

                        var packages = new Gee.ArrayList<string> ();
                        foreach (var err in error) {
                            if (err.has_prefix ("  ")) {
                                string[] strs = err.strip ().split (" ");
                                if (strs[strs.length - 1].has_suffix ("]") && strs[strs.length - 1].has_prefix ("[")) {
                                    packages.add ("%s (%s)".printf (
                                        strs[0],
                                        strs[strs.length - 1][1: strs[strs.length - 1].length - 1]
                                    ));

                                } else {
                                    packages.add (strs[0]);
                                }
                            }
                        }

                        var answer = give_choice (packages.to_array ());

                        if (answer != null) {
                            replace_strings_in_array (ref ca.command_argv, package, answer.split (" ")[0]);

                        } else {
                            return status;
                        }
                        break;

                    case ErrorType.NONE:
                        print_error (_("Unknown error message: '%s'").printf (error_message));
                        print_issue ();
                        return Constants.ExitCode.BASE_ERROR;

                    default:
                        assert_not_reached ();
                }

            } else {
                return status;
            }
        }
    }

    internal async int info (CommandArgs ca) {
        int status_code = Constants.ExitCode.SUCCESS;

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

        return Constants.ExitCode.SUCCESS;
    }

    int apa_moo (CommandArgs ca) {
        if (ca.command_argv.length > 0) {
            print (Moo.get_moo (ca.command_argv[0]), false);

        } else {
            print (Moo.get_moo (), false);
        }

        return Constants.ExitCode.SUCCESS;
    }

    public void check_is_root (string command) {
        if (is_root ()) {
            return;
        }

        print_error (_("Need root previlegies for '%s' command").printf (command));
        print (_("Aborting."));
        Process.exit (Constants.ExitCode.BASE_ERROR);
    }
}
