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

    public async int run (owned string[] argv) {

        string? command = cut_of_command (ref argv);
        string? subcommand = null;

        if (command == null) {
            Help.print_apa ();
            return ExitCode.SUCCESS;
        }

        var entity = CommandEntity.find (Commands.Data.all_commands (), command);

        if (entity == null) {
            //  print (command);
            print_error (_("Unknown command `%s'").printf (command));
            return ExitCode.BASE_ERROR;
        }

        CommandEntity? subcommand_entity = null;
        if (entity.subcommands != null) {
            subcommand = cut_of_command (ref argv);

            if (subcommand != null) {
                subcommand_entity = CommandEntity.find (entity.subcommands.to_array (), subcommand);

                if (subcommand_entity == null) {
                    print_error (_("Unknown subcommand `%s' of `%s' command").printf (subcommand, command));
                    return ExitCode.BASE_ERROR;
                }
            } else {
                Help.print_command_help (command, subcommand);
                return ExitCode.SUCCESS;
            }

        } else if (entity.subcommands != null && subcommand_entity == null) {
            print_error (_("No subcommand. Try `apa %s --help'").printf (command));
            return ExitCode.BASE_ERROR;
        }

        if ("-h" in argv || "--help" in argv) {
            Help.print_command_help (command, subcommand);
            return ExitCode.SUCCESS;
        }

        if ("-v" in argv || "--version" in argv) {
            print_version ();
            return ExitCode.SUCCESS;
        }

        CommandEntity current_entity = subcommand_entity ?? entity;

        if (current_entity.need_root) {
            check_is_root (current_entity.name);
        }
        if (current_entity.need_no_packagekit) {
            check_pk_is_not_running ();
        }

        try {
            var args_handler = new ArgsHandler (argv);
            args_handler.init_options (
                current_entity.options.to_array (),
                current_entity.arg_options.to_array ()
            );

            switch (command) {
                case Commands.Data.KERNEL_COMMAND:
                    switch (subcommand) {
                        case Commands.Data.KERNEL_UPGRADE_SUBCOMMAND:
                            return yield Kernel.upgrade (args_handler);

                        case Commands.Data.KERNEL_LIST_SUBCOMMAND:
                            return yield Kernel.list (args_handler);

                        default:
                            assert_not_reached ();
                    }

                case Commands.Data.TASK_COMMAND:
                    switch (subcommand) {
                        case Commands.Data.TASK_SEARCH_SUBCOMMAND:
                            return yield Task.search (args_handler);

                        case Commands.Data.TASK_SHOW_SUBCOMMAND:
                            return yield Task.show (args_handler);

                        case Commands.Data.TASK_INSTALL_SUBCOMMAND:
                            return yield Task.install (args_handler);

                        case Commands.Data.TASK_LIST_SUBCOMMAND:
                            return yield Task.list (args_handler);

                        default:
                            assert_not_reached ();
                    }

                case Commands.Data.CONFIG_COMMAND:
                    switch (subcommand) {
                        case Commands.Data.CONFIG_RESET_SUBCOMMAND:
                            return yield Config.reset (args_handler);

                        case Commands.Data.CONFIG_LIST_SUBCOMMAND:
                            return yield Config.list (args_handler);

                        case Commands.Data.CONFIG_GET_SUBCOMMAND:
                            return yield Config.get (args_handler);

                        case Commands.Data.CONFIG_SET_SUBCOMMAND:
                            return yield Config.set (args_handler);

                        default:
                            assert_not_reached ();
                    }

                case Commands.Data.REPO_COMMAND:
                    switch (subcommand) {
                        case Commands.Data.REPO_LIST_SUBCOMMAND:
                            return yield Repo.list (args_handler);

                        case Commands.Data.REPO_ADD_SUBCOMMAND:
                            return yield Repo.add (args_handler);

                        case Commands.Data.ADD_AIDES_SUBCOMMAND:
                            return yield Repo.add_aides (args_handler);

                        case Commands.Data.REMOVE_AIDES_SUBCOMMAND:
                            return yield Repo.remove_aides (args_handler);

                        case Commands.Data.REPO_REMOVE_SUBCOMMAND:
                            return yield Repo.remove (args_handler);

                        default:
                            assert_not_reached ();
                    }

                case AptGet.AUTOREMOVE:
                    return yield autoremove (args_handler);

                case AptGet.DO:
                    return yield @do (args_handler);

                case AptGet.UPDATE:
                    return yield update (args_handler);

                case AptGet.UPGRADE:
                    return yield upgrade (args_handler);

                case AptGet.INSTALL:
                    return yield install (args_handler);

                case Commands.Data.REINSTALL_COMMAND:
                    return yield reinstall (args_handler);

                case AptGet.REMOVE:
                    return yield remove (args_handler);

                case AptGet.SOURCE:
                    return yield source (args_handler);

                case AptCache.SEARCH:
                    return yield search (args_handler);

                case Commands.Data.LIST_COMMAND:
                    return yield list (args_handler);

                case Commands.Data.INFO_COMMAND:
                    return yield info (args_handler);

                case Commands.Data.SEARCH_FILE_COMMAND:
                    return yield search_file (args_handler);

                case Commands.Data.MOO_COMMAND:
                    return moo (args_handler);

                case Commands.Data.VERSION_COMMAND:
                    print_version ();
                    return ExitCode.SUCCESS;

                case Commands.Data.HELP_COMMAND:
                    Help.print_apa ();
                    return ExitCode.SUCCESS;

                default:
                    assert_not_reached ();
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
                    print_error (_("There are too many arguments"));
                    return ExitCode.BASE_ERROR;

                case CommandError.TOO_FEW_ARGS:
                    print_error (_("There are too few arguments"));
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
