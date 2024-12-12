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

namespace Apa.Descriptions {

    public const string NO_DESCRIPTION = "NO DESCRIPTION";

    public string apa () {
        return _("APA — ALT Packages Assistant. Your best friend in this cruel world of many package tools.");
    }
}

namespace Apa.Commands.Descriptions {

    public string install () {
        return _("The command to install packages. The following arguments can be passed: a regex pattern of the package name; a file belonging to the package; a task number. Attention: only one task number can be passed, and when it is detected, all other arguments will be ignored. The `apa task' command is recommended for working with tasks.");
    }

    public string reinstall () {
        return _("Reinstall the package. Same as 'apa install --reinstall <..>'.");
    }

    public string remove () {
        return _("The command to remove packages using a regex expression.");
    }

    public string @do () {
        return _("A command that combines the installation and removal of packages. The postfix `+' is used for installation, and for deletion `-'.");
    }

    public string update () {
        return _("Need for resynchronize the package index files from their sources. The indexes of available packages are fetched from the location(s) specified in /etc/apt/sources.list.");
    }

    public string upgrade () {
        return _("upgrade is used to install the newest versions of all packages currently installed on the system from the sources enumerated in /etc/apt/sources.list. Packages currently installed with new versions available are retrieved and upgraded; under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. New versions of currently installed packages that cannot be upgraded without changing the install status of another package will be left at their current version. An update must be performed first so that apa knows that new versions of packages are available. Performs automatic updates based on `auto-update' of the apa config.");
    }

    public string search () {
        return _("Search performs a full text search on all available package lists for the regex pattern given. It searches the package names and the descriptions for an occurrence of the regular expression and prints out the package name and the short description. If --full is given then output identical to show is produced for each matched package, and if --names-only is given then the long description is not searched, only the package name is.");
    }

    public string kernel () {
        return _("A subcommand for working with the kernel.");
    }

    public string config () {
        return _("A subcommand for working with the apa config.");
    }

    public string task () {
        return _("A subcommand for working with tasks.");
    }

    public string autoremove () {
        return _("Remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed. Warning: Use this command carefully.");
    }

    public string source () {
        return Apa.Descriptions.NO_DESCRIPTION;
    }

    public string list () {
        return _("Display a list of installed packages.");
    }

    public string info () {
        return _("Show information about package.");
    }

    public string search_file () {
        return _("Perform a file search among the packages in the repository. It supports searching among installed packages using the --local option.");
    }

    public string help () {
        return _("Show this help text. Same as `apa --help'.");
    }

    public string version () {
        return _("Print apa version. Same as `apa --version'.");
    }
}

namespace Apa.AptCache.Descriptions {

    public string option_package_cache () {
        return _("The file to store the package cache. The package cache is the primary cache used by all operations.");
    }

    public string option_source_cache () {
        return _("The file to store the source cache. The source is used only by gencaches and it stores a parsed version of the package information from remote sources. When building the package cache the source cache is used to advoid reparsing all of the package files.");
    }

    public string option_hide_progress () {
        return _("Do not show the progress bar. Suitable for logs.");
    }

    public string option_important_only () {
        return _("Print only important dependencies; for use with unmet. Causes only Depends and Pre-Depends relations to be printed.");
    }

    public string option_names_only () {
        return _("Only search on the package names, not the long descriptions.");
    }

    public string arg_option_option () {
        return _("Set a APT Configuration Option; This will set an arbitrary configuration option. The syntax is `-o Foo::Bar=bar' or `--option=Foo::Bar=bar'.");
    }

    public string arg_option_config () {
        return _("Path to APT Configuration File; Specify a configuration file to use. The program will read the default configuration file and then this
              configuration file. If configuration settings need to be set before the default configuration files are parsed specify a file
              with the APT_CONFIG environment variable. See apt.conf(5) for syntax information.");
    }
}

namespace Apa.Config.Descriptions {

    public string option_all () {
        return _("Reset entire config to defaults values.");
    }

    public string config_auto_update () {
        return _("Run `apa update' automatically before some commands");
    }

    public string config_use_fuzzy_search () {
        return _("Use fuzzy search in case of unsuccessful search via `apa search'");
    }
}

namespace Apa.AptGet.Descriptions {

    public string option_all () {
        return _("Reset entire config to defaults values.");
    }

    public string config_auto_update () {
        return _("Run `apa update' automatically before some commands");
    }

    public string config_use_fuzzy_search () {
        return _("Use fuzzy search in case of unsuccessful search via `apa search'");
    }
}
