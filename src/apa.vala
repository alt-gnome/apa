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

    public async int run (string[] argv) {

        var command_handler = CommandHandler.parse (argv);

        if ("-h" in command_handler.options || "--help" in command_handler.options) {
            Help.print_help (command_handler.command);
            return Constants.ExitCode.SUCCESS;
        }

        if ("-v" in command_handler.options || "--version" in command_handler.options) {
            print (get_version ());
            return Constants.ExitCode.SUCCESS;
        }

        try {
            switch (command_handler.command) {
                case KERNEL_COMMAND:
                    return yield kernel (SubCommandHandler.convert_from_ch (command_handler));

                case TASK_COMMAND:
                    return yield task (SubCommandHandler.convert_from_ch (command_handler));

                case Get.AUTOREMOVE:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield autoremove (command_handler);

                case Get.DO:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield @do (command_handler);

                case Get.UPDATE:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield update (command_handler);

                case Get.UPGRADE:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield upgrade (command_handler);

                case Get.INSTALL:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield install (command_handler);

                case Get.REINSTALL:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield reinstall (command_handler);

                case Get.REMOVE:
                    check_pk_is_not_running ();
                    check_is_root (command_handler.command);
                    return yield remove (command_handler);

                case Get.SOURCE:
                    return yield source (command_handler);

                case Cache.SEARCH:
                    return yield Cache.search (command_handler);

                case Repo.REPO_LIST:
                    return yield Repo.repo_list (command_handler);

                case Repo.TEST:
                    check_is_root (command_handler.command);
                    return yield Repo.test (command_handler);

                case LIST_COMMAND:
                    return yield Rpm.list (command_handler);

                case INFO_COMMAND:
                    return yield info (command_handler);

                case MOO_COMMAND:
                    return moo (command_handler);

                case VERSION_COMMAND:
                    print (get_version ());
                    return Constants.ExitCode.SUCCESS;

                case HELP_COMMAND:
                    Help.print_apa ();
                    return Constants.ExitCode.SUCCESS;

                case null:
                    Help.print_apa ();
                    return Constants.ExitCode.BASE_ERROR;

                default:
                    print_error (_("Unknown command '%s'").printf (command_handler.command));
                    return Constants.ExitCode.BASE_ERROR;
            }

        } catch (CommandError e) {
            switch (e.code) {
                case CommandError.UNKNOWN_ERROR:
                    print_error (_("Unknown error message: '%s'").printf (e.message));
                    print_create_issue (e.message, argv);
                    return Constants.ExitCode.BASE_ERROR;

                case CommandError.UNKNOWN_OPTION:
                    print_error (_("Unknown option: '%s'").printf (e.message));
                    break;

                case CommandError.UNKNOWN_ARG_OPTION:
                    print_error (_("Unknown option with value: '%s'").printf (e.message));
                    break;

                default:
                    print_error (e.message);
                    break;
            }
            return Constants.ExitCode.BASE_ERROR;

        } catch (ApiBase.CommonError e) {
            print_error ("Something went wrong");
            return Constants.ExitCode.BASE_ERROR;

        } catch (ApiBase.BadStatusCodeError e) {
            print_error (_("Bad status code: '%d: %s'").printf (e.code, e.message));
            return Constants.ExitCode.BASE_ERROR;
        }
    }

    public void check_is_root (string command) {
        if (is_root ()) {
            return;
        }

        print_error (_("Need root previlegies for '%s' command").printf (command));
        Process.exit (Constants.ExitCode.BASE_ERROR);
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
        Process.exit (Constants.ExitCode.BASE_ERROR);
    }
}
