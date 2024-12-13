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

    const string CONFIG_COMMAND = "config";
    const string KERNEL_COMMAND = "kernel";
    const string LIST_COMMAND = "list";
    const string INFO_COMMAND = "info";
    const string MOO_COMMAND = "moo";
    const string TASK_COMMAND = "task";
    const string HELP_COMMAND = "help";
    const string VERSION_COMMAND = "version";
    const string SEARCH_FILE_COMMAND = "search-file";
    const string REPO_COMMAND = "repo";
    const string REINSTALL_COMMAND = "reinstall";

    const CommandDescriptionEntity[] VISIBLE_COMMANDS = {
        { AptGet.INSTALL, Commands.Descriptions.install, true },
        { REINSTALL_COMMAND, Commands.Descriptions.reinstall, true },
        { AptGet.REMOVE, Commands.Descriptions.remove, true },
        { AptGet.DO, Commands.Descriptions.do, true },
        { AptGet.UPDATE, Commands.Descriptions.update, true },
        { AptGet.UPGRADE, Commands.Descriptions.upgrade, true },
        { AptCache.SEARCH, Commands.Descriptions.search, false },
        { KERNEL_COMMAND, Commands.Descriptions.kernel, false },
        { CONFIG_COMMAND, Commands.Descriptions.config, false },
        { TASK_COMMAND, Commands.Descriptions.task, false },
        { AptGet.AUTOREMOVE, Commands.Descriptions.autoremove, true },
        //  { AptGet.SOURCE, Commands.Descriptions.source, true },
        { LIST_COMMAND, Commands.Descriptions.list, false },
        { INFO_COMMAND, Commands.Descriptions.info, false },
        { SEARCH_FILE_COMMAND, Commands.Descriptions.search_file, false },
        { HELP_COMMAND, Commands.Descriptions.help, false },
        { VERSION_COMMAND, Commands.Descriptions.version, false },
    };

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

                case CONFIG_COMMAND:
                    return yield config (argv);

                case REPO_COMMAND:
                    return yield repo (argv);

                case AptGet.AUTOREMOVE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield autoremove (args_handler);

                case AptGet.DO:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield @do (args_handler);

                case AptGet.UPDATE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield update (args_handler);

                case AptGet.UPGRADE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield upgrade (args_handler);

                case AptGet.INSTALL:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield install (args_handler);

                case REINSTALL_COMMAND:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield reinstall (args_handler);

                case AptGet.REMOVE:
                    check_pk_is_not_running ();
                    check_is_root (command);
                    return yield remove (args_handler);

                case AptGet.SOURCE:
                    return yield source (args_handler);

                case AptCache.SEARCH:
                    return yield search (args_handler);

                case LIST_COMMAND:
                    return yield Rpm.list (args_handler);

                case INFO_COMMAND:
                    return yield info (args_handler);

                case SEARCH_FILE_COMMAND:
                    return yield search_file (args_handler);

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

                case CommandError.UNKNOWN_SUBCOMMAND:
                    print_error (_("Unknown subcommand `%s'").printf (e.message));
                    return ExitCode.BASE_ERROR;

                case CommandError.TOO_MANY_ARGS:
                    print_error (_("Too many arguments"));
                    return ExitCode.BASE_ERROR;

                case CommandError.TASK_IS_UNKNOWN:
                    print_error (_("Task `%s' is unknown or still building").printf (e.message));
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

                case ApiBase.CommonError.SOUP:
                    print_error ("Cant send request. Probably internet connection problems");
                    break;

                default:
                    print_error ("Something went wrong");
                    break;
            }

            return ExitCode.BASE_ERROR;

        } catch (ApiBase.BadStatusCodeError e) {
            switch (e.code) {
                case ApiBase.BadStatusCodeError.NOT_FOUND:
                    print_error (_("Nothing found"));
                    return ExitCode.BASE_ERROR;

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
