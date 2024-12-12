/*
 * Copyright (C) 2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Apa.Help {

    void print_help (string? command) {
        switch (command) {
            case AptGet.UPDATE:
                print_update ();
                return;

            case AptGet.UPGRADE:
                print_upgrade ();
                return;

            case AptGet.INSTALL:
                print_install ();
                return;

            case AptGet.REMOVE:
                print_remove ();
                return;

            case AptGet.SOURCE:
                print_source ();
                return;

            case AptCache.SEARCH:
                assert_not_reached ();

            case Apa.LIST_COMMAND:
                assert_not_reached ();

            case Apa.INFO_COMMAND:
                assert_not_reached ();

            case Apa.MOO_COMMAND:
                print_moo ();
                return;

            case Apa.VERSION_COMMAND:
                print_version ();
                return;

            case Apa.HELP_COMMAND:
                print_apa ();
                return;

            case null:
                print_apa ();
                return;

            default:
                print_error (_("No help for `%s'").printf (command));
                print_apa ();
                return;
        }
    }

    void print_usage (string usage) {
        print ("");
        print (_("Usage:"));
        print ("\t" + usage);
    }

    void print_option (string option, string desc) {
        print ("\t" + option);
        print ("\t\t" + desc);
        print ("");
    }

    void print_common_get_options () {
        print ("");
        print (_("Common options:"));
        print ("");
        print_option (
            "-h, --hide-progress",
            _("Hide progress bar for logging")
        );
        print_option (
            "-q, --quiet",
            _("Hide any command output")
        );
        print_option (
            "-s, --simulate",
            _("Simulate command execution")
        );
        print_option (
            "-y, --yes",
            _("Always `yes'")
        );
        print_option (
            "-f, --fix",
            _("Try to fix")
        );
        print_option (
            "-m, --missing-ignore",
            _("Ignore missing packages")
        );
        print_option (
            "-V, --version-detailed",
            _("Display detailed packages version")
        );
        print_option (
            "-c=?, --config=?",
            _("Read configuration file")
        );
        print_option (
            "-o=?, --option=?",
            _("Set an arbitary configuration option, eg -o=dir::cache=/tmp")
        );
    }

    void print_common_cache_options () {
        print ("");
        print (_("Common options:"));
        print ("");
        print_option (
            "-h, --hide-progress",
            _("Hide progress bar for logging")
        );
        print_option (
            "-i, --important-only",
            _("Show only important dependencies for the unmet command")
        );
        print_option (
            "-s, --source-cache",
            _("The source cache")
        );
        print_option (
            "-p, --package-cache",
            _("The package cache")
        );
        print_option (
            "-c=?, --config=?",
            _("Read configuration file")
        );
        print_option (
            "-o=?, --option=?",
            _("Set an arbitary configuration option, eg -o=dir::cache=/tmp")
        );
    }

    string get_update_desc () {
        return C_(
            "update command",
            "Command for update"
        );
    }

    string get_upgrade_desc () {
        return C_(
            "upgrade command",
            "Command for upgrade"
        );
    }

    string get_install_desc () {
        return C_(
            "instal command",
            "Command for install"
        );
    }

    string get_remove_desc () {
        return C_(
            "remove command",
            "Command for remove"
        );
    }

    string get_source_desc () {
        return C_(
            "source command",
            "Command for source"
        );
    }

    string get_search_desc () {
        return C_(
            "search command",
            "Command for search"
        );
    }

    string get_version_desc () {
        return C_(
            "version command",
            "Display APA version"
        );
    }

    string get_kernel_desc () {
        return C_(
            "kernel command",
            "Command for kernel"
        );
    }

    public void print_apa (bool with_desc = true) {
        print (Descriptions.apa ());
        print ("");
        foreach (var entiry in VISIBLE_COMMANDS) {
            print (cyan_text (entiry.name));
            print ("  " + entiry.description_getter ());

            if (entiry.need_root_rights) {
                print (_("Need root privileges."));
            }

            print ("");
        }
    }

    public void print_update () {
        print (get_update_desc ());
        print_usage ("apa update [OPTIONS[=VALUE]]");
        print_common_get_options ();
        print ("");
    }

    public void print_upgrade () {
        print (get_upgrade_desc ());
        print_usage ("apa upgrade [OPTIONS[=VALUE]]");
        print_common_get_options ();
        print ("");
        print (_("Command options:"));
        print ("");
        print_option (
            "-d, --download-only",
            _("Only download packages, without installing")
        );
        print_option (
            "-u, --upgraded-show",
            _("Display upgraded packages")
        );
        print ("");
    }

    public void print_install () {
        print (get_install_desc ());
        print_usage ("apa install [OPTIONS[=VALUE]] <package1> <package2> ..");
        print_common_get_options ();
        print ("");
        print (_("Command options:"));
        print ("");
        print_option (
            "-d, --download-only",
            _("Only download packages, without installing")
        );
        print ("");
    }

    public void print_remove () {
        print (get_remove_desc ());
        print_usage ("apa remove [OPTIONS[=VALUE]] <package1> <package2> ..");
        print_common_get_options ();
        print ("");
        print (_("Command options:"));
        print ("");
        print_option (
            "-D, --with-dependecies",
            _("Remove with dependencies")
        );
        print ("");
    }

    public void print_source () {
        print (get_source_desc ());
        print_usage ("apa source [OPTIONS[=VALUE]] <package1> <package2> ..");
        print_common_get_options ();
        print ("");
        print (_("Command options:"));
        print ("");
        print_option (
            "-b, --build",
            _("Build packages")
        );
        print ("");
    }

    public void print_search () {
        print (get_search_desc ());
        print_usage ("apa search [OPTIONS[=VALUE]] <regex1> <regex2> ..");
        print_common_cache_options ();
        print ("");
    }

    public void print_kernel () {
        print (get_kernel_desc ());
    }

    public void print_task () {
        print ("");
    }

    public void print_config () {
        print ("");
    }

    public void print_test () {

    }

    public void print_repo () {

    }

    public void print_moo () {
        print (C_("cow", "Mooage:"));
        print ("\tapa moo [PHRASE]");
        print ("");
    }

    public void print_version () {
        print (get_version_desc ());
        print_usage ("apa version");
        print ("");
        print ("Equal to:");
        print ("\tapa --version");
        print ("");
    }
}
