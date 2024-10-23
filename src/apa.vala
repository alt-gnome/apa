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
                case Get.INSTALL:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield install (ca);

                case Get.REMOVE:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield remove (ca);

                case Get.UPDATE:
                    check_pk_is_not_running ();
                    check_is_root (ca.command);
                    return yield Get.update ();

                case Cache.SEARCH:
                    return yield Cache.search (ca.command_argv, ca.options);

                case LIST_COMMAND:
                    return yield Rpm.list_installed (ca.options);

                case INFO_COMMAND:
                    return yield info (ca);

                case MOO_COMMAND:
                    return moo (ca);

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

    public void check_is_root (string command) {
        if (is_root ()) {
            return;
        }

        print_error (_("Need root previlegies for '%s' command").printf (command));
        print (_("Aborting."));
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
        print (_("Aborting."));
        Process.exit (Constants.ExitCode.BASE_ERROR);
    }
}
