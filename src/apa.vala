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

    const string KERNEL_COMMAND = "kernel";
    const string LIST_COMMAND = "list";
    const string INFO_COMMAND = "info";
    const string MOO_COMMAND = "moo";
    const string TASK_COMMAND = "task";
    const string HELP_COMMAND = "help";
    const string VERSION_COMMAND = "version";

    public async int run (owned string[] argv) {

        string? command = cut_of_command (ref argv);

        if (command == null && argv.length == 0) {
            Help.print_apa ();
            return ExitCode.SUCCESS;

        } else if (command == null && argv.length > 0) {
            if ("-h" in argv || "--help" in argv) {
                Help.print_help (command);
                return ExitCode.SUCCESS;
            }

            if ("-v" in argv || "--version" in argv) {
                print (get_version ());
                return ExitCode.SUCCESS;
            }
        }

        var args_handler = new ArgsHandler (argv);

        try {
            switch (command) {
                case KERNEL_COMMAND:
                    return yield kernel (argv);

                case TASK_COMMAND:
                    return yield task (argv);

                case Get.AUTOREMOVE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield autoremove (args_handler);

                case Get.DO:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield @do (args_handler);

                case Get.UPDATE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield update (args_handler);

                case Get.UPGRADE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield upgrade (args_handler);

                case Get.INSTALL:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield install (args_handler);

                case Get.REINSTALL:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield reinstall (args_handler);

                case Get.REMOVE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield remove (args_handler);

                case Get.SOURCE:
                    return yield source (args_handler);

                case Cache.SEARCH:
                    return yield search (args_handler);

                case Repo.REPO_LIST:
                    return yield Repo.repo_list (args_handler);

                case Repo.TEST:
                    check_is_root (command);
                    return yield Repo.test (args_handler);

                case LIST_COMMAND:
                    return yield Rpm.list (args_handler);

                case INFO_COMMAND:
                    return yield info (args_handler);

                case MOO_COMMAND:
                    return moo (args_handler);

                case VERSION_COMMAND:
                    print (get_version ());
                    return ExitCode.SUCCESS;

                case HELP_COMMAND:
                    Help.print_apa ();
                    return ExitCode.SUCCESS;

                case null:
                    Help.print_apa ();
                    return ExitCode.BASE_ERROR;

                default:
                    print_error (_("Unknown command `%s'").printf (command));
                    return ExitCode.BASE_ERROR;
            }

        } catch (CommandError e) {
            switch (e.code) {
                case CommandError.UNKNOWN_ERROR:
                    print_error (_("Unknown error message: `%s'").printf (e.message));
                    print_create_issue (e.message, argv);
                    return ExitCode.BASE_ERROR;

                default:
                    print_error (e.message);
                    break;
            }

            return ExitCode.BASE_ERROR;

        } catch (ApiBase.CommonError e) {
            switch (e.code) {
                case ApiBase.CommonError.ANSWER:
                    print_error (e.message);
                    break;

                default:
                    print_error ("Something went wrong");
                    break;
            }

            return ExitCode.BASE_ERROR;

        } catch (ApiBase.BadStatusCodeError e) {
            switch (e.code) {
                case ApiBase.BadStatusCodeError.NOT_FOUND:
                    print (_("Nothing found"));
                    return ExitCode.SUCCESS;

                default:
                    print_error (_("Bad status code: `%d: %s'").printf (e.code, e.message.strip ()));
                    break;
            }

            return ExitCode.BASE_ERROR;

        } catch (OptionsError e) {
            switch (e.code) {
                case OptionsError.NO_ARG_OPTION_VALUE:
                    print_error (_("Option `%s' need value").printf (e.message));
                    break;

                case OptionsError.UNKNOWN_OPTION:
                    print_error (_("Unknown option: `%s'").printf (e.message));
                    break;

                case OptionsError.UNKNOWN_ARG_OPTION:
                    print_error (_("Unknown option with value: `%s'").printf (e.message));
                    break;

                default:
                    print_error (e.message);
                    break;
            }

            return ExitCode.BASE_ERROR;
        }
    }

    public void check_is_root (string command) {
        if (is_root ()) {
            return;
        }

        print_error (_("Need root previlegies for `%s' command").printf (command));
        Process.exit (ExitCode.BASE_ERROR);
    }

    public void check_pk_is_not_running () {
        try {
            if (!pk_is_running ()) {
                return;
            }
        } catch (Error e) {
            print_error (e.message);
        }

        print_error (_("PackageKit is running"));
        Process.exit (ExitCode.BASE_ERROR);
    }
}
