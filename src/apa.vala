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

    const string LIST_COMMAND = "list";
    const string INFO_COMMAND = "info";
    const string MOO_COMMAND = "moo";
    const string HELP_COMMAND = "help";
    const string VERSION_COMMAND = "version";

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
                case Get.UPDATE:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield update (ca);

                case Get.UPGRADE:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield upgrade (ca);

                case Get.INSTALL:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield install (ca);

                case Get.REMOVE:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield remove (ca);

                case Get.SOURCE:
                    return yield source (ca);

                case Cache.SEARCH:
                    return yield Cache.search (ca.command_argv, ca.options, ca.arg_options);

                case Repo.REPO_LIST:
                    return yield Repo.repo_list (ca.options, ca.arg_options);

                case Repo.TEST:
                    check_is_root (ca.command);
                    return yield Repo.test (ca.command_argv, ca.options, ca.arg_options);

                case LIST_COMMAND:
                    return yield Rpm.list (ca.options, ca.arg_options);

                case INFO_COMMAND:
                    return yield info (ca);

                case MOO_COMMAND:
                    return moo (ca);

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
                    print_error (_("Unknown command '%s'").printf (ca.command));
                    Help.print_apa (false);
                    return Constants.ExitCode.BASE_ERROR;
            }

        } catch (Error e) {
            print_error (e.message);
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
