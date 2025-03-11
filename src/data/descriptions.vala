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

    public inline string apa () {
        return _("APA — ALT Package Assistant. Your best friend in this cruel world of many package tools.");
    }
}

namespace Apa.Commands.Descriptions {

    public inline string moo () {
        return _("Moo powers of APA.");
    }

    public inline string install () {
        return _("Command to install packages. The following arguments can be passed: a regex pattern of the package name; a file belonging to the package; a task number. Attention: only one task number can be passed, and when it is detected, all other arguments will be ignored. The `apa task' command is recommended for working with tasks.");
    }

    public inline string reinstall () {
        return _("Command to reinstall packages. Same as `apa install --reinstall <..>'.");
    }

    public inline string remove () {
        return _("Command to remove packages using a regex.");
    }

    public inline string @do () {
        return _("Command that combines the installation and removal of packages. The postfix `+' is used for installation, and for deletion `-'.");
    }

    public inline string update () {
        return _("Need for resynchronize the package index files from their sources. The indexes of available packages are fetched from the location(s) specified in `/etc/apt/sources.list'.");
    }

    public inline string upgrade () {
        return _("The `upgrade' command is used to install the newest versions of all packages currently installed on the system from the sources enumerated in `/etc/apt/sources.list'. Packages currently installed with new versions available are retrieved and upgraded; under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. New versions of currently installed packages that cannot be upgraded without changing the install status of another package will be left at their current version. An update must be performed first so that apa knows that new versions of packages are available. Performs automatic updates based on `auto-update' of the APA config.");
    }

    public inline string search () {
        return _("The `search' command performs a full text search on all available package lists for the regex pattern given. It searches the package names and the descriptions for an occurrence of the regular expression and prints out the package name and the short description. Has `--installed' flag to search only among the installed packages.");
    }

    public inline string kernel () {
        return _("A subcommand for working with the kernel.");
    }

    public inline string kernel_upgrade () {
        return _("Upgrade kernel.");
    }

    public inline string kernel_list () {
        return _("Print list of available kernels.");
    }

    public inline string config () {
        return _("A subcommand for working with the APA config.");
    }

    public inline string config_reset () {
        return _("Reset config value by it key. You can reset entire config with `--all' option.");
    }

    public inline string config_list () {
        return _("List all possible keys values.");
    }

    public inline string config_get () {
        return _("Get config value by it key.");
    }

    public inline string config_set () {
        return _("Set config value by pairs ob `key=value'.");
    }

    public inline string task () {
        return _("A subcommand for working with tasks.");
    }

    public inline string task_add () {
        return _("Add task as repository.");
    }

    public inline string task_search () {
        return _("Search task by owner, branch, package name, etc.");
    }

    public inline string task_show () {
        return _("Show task information with state and all subtasks.");
    }

    public inline string task_install () {
        return _("Install task by task number. You can pass tasks packages names next to task number.");
    }

    public inline string task_list_packages () {
        return _("List task packages.");
    }

    public inline string repo () {
        return _("A subcommand for working with repositories.");
    }

    public inline string repo_list () {
        return _("Show enabled sources in system.");
    }

    public inline string repo_add () {
        return _("Add source to sources list. Sources format described at apt-repo(8).");
    }

    public inline string repo_add_aides () {
        return _("Add Aides Repo to sources list.");
    }

    public inline string repo_remove_aides () {
        return _("Remove Aides Repo from sources list.");
    }

    public inline string repo_remove () {
        return _("Remove source from sources list.");
    }

    public inline string autoremove () {
        return _("Remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed. Warning: Use this command carefully.");
    }

    public inline string source () {
        return Apa.Descriptions.NO_DESCRIPTION;
    }

    public inline string list () {
        return _("Display a list of installed packages.");
    }

    public inline string info () {
        return _("Show information about package.");
    }

    public inline string search_file () {
        return _("Perform a file search among the packages in the repository. It supports searching among installed packages using the `--installed' option.");
    }

    public inline string help () {
        return _("Show this help text. Same as `apa --help'.");
    }

    public inline string version () {
        return _("Print APA version. Same as `apa --version'.");
    }
}

namespace Apa.AptCache.Descriptions {

    public inline string option_package_cache () {
        return _("The file to store the package cache. The package cache is the primary cache used by all operations.");
    }

    public inline string option_source_cache () {
        return _("The file to store the source cache. The source is used only by gencaches and it stores a parsed version of the package information from remote sources. When building the package cache the source cache is used to avoid reparsing all of the package files.");
    }

    public inline string option_hide_progress () {
        return _("Do not show the progress bar. Suitable for logs.");
    }

    public inline string option_important_only () {
        return _("Print only important dependencies; for use with unmet. Causes only Depends and Pre-Depends relations to be printed.");
    }

    public inline string option_full () {
        return _("Print full package records when searching.");
    }

    public inline string option_recursive () {
        return _("Make dependencies recursive so that all packages mentioned are printed once.");
    }

    public inline string option_names_only () {
        return _("Only search on the package names, not the long descriptions.");
    }

    public inline string option_installed () {
        return _("Search among installed packages. Works well with `--names-only' option");
    }

    public inline string arg_option_option () {
        return _("Set a APT Configuration Option; This will set an arbitrary configuration option. The syntax is `-o Foo::Bar=bar' or `--option=Foo::Bar=bar'.");
    }

    public inline string arg_option_config_file () {
        return _("Path to APT Configuration File; Specify a configuration file to use. The program will read the default configuration file and then this configuration file. If configuration settings need to be set before the default configuration files are parsed specify a file with the APT_CONFIG environment variable. See apt.conf(5) for syntax information.");
    }
}

namespace Apa.Config.Descriptions {

    public inline string option_all () {
        return _("Reset entire config to defaults values.");
    }

    public inline string config_auto_update () {
        return _("Run `apa update' automatically before some commands.");
    }

    public inline string config_use_fuzzy_search () {
        return _("Use fuzzy search in case of unsuccessful install via `apa install'.");
    }

    public inline string config_auto_upgrade_kernel () {
        return _("Automatically upgrade the kernel when executing an `apa upgrade'.");
    }
}

namespace Apa.AptGet.Descriptions {

    public inline string option_hide_progress () {
        return AptCache.Descriptions.option_hide_progress ();
    }

    public inline string option_quiet () {
        return _("Don't print any to stdout.");
    }

    public inline string option_simulate () {
        return _("No-act. Perform ordering simulation.");
    }

    public inline string option_yes () {
        return _("Assume `Yes' to all queries and do not prompt.");
    }

    public inline string option_fix () {
        return _("Attempt to continue if the integrity check fails.");
    }

    public inline string option_version_detailed () {
        return _("Show verbose version numbers.");
    }

    public inline string option_no_download () {
        return _("Disables downloading of packages. This is best used with `--ignore-missing' to force APT to use only the `.rpm' it has already downloaded.");
    }

    public inline string option_ignore_missing () {
        return _("Ignore missing packages; If packages cannot be retrieved or fail the integrity check after retrieval (corrupted package files), hold back those packages and handle the result.");
    }

    public inline string arg_option_option () {
        return AptCache.Descriptions.arg_option_option ();
    }

    public inline string arg_option_config_file () {
        return AptCache.Descriptions.arg_option_config_file ();
    }

    public inline string option_download_only () {
        return _("Download only - do NOT install or unpack archives.");
    }

    public inline string option_upgraded_show () {
        return _("Show a list of upgraded packages as well.");
    }

    public inline string option_with_kernel () {
        return _("Also upgrade kernel.");
    }

    public inline string option_with_dependencies () {
        return _("When removing packages, remove dependencies as possible.");
    }

    public inline string option_reinstall () {
        return _("Reinstall packages.");
    }

    public inline string option_build () {
        return _("Build the source package after fetching it.");
    }
}

namespace Apa.List.Descriptions {

    public inline string option_installed () {
        return _("Show installed packages.");
    }

    public inline string option_can_be_upgraded () {
        return _("Show packages that can be upgraded.");
    }
}

namespace Apa.AptRepo.Descriptions {

    public inline string option_simulate () {
        return _("No-act. Changes only shown, is not performed.");
    }

    public inline string option_hsh_apt_config () {
        return _("Need for the special case when you want to use hasher(7) together with a local APT configuration.");
    }

    public inline string option_all () {
        return _("List all repositories.");
    }
}

namespace Apa.Search.Descriptions {

    public inline string option_names_only () {
        return _("Only search on the package names, not the long descriptions.");
    }

    public inline string option_installed () {
        return _("Search among installed packages. Works well with `--names-only' option");
    }
}

namespace Apa.Rpm.Descriptions {

    public inline string arg_option_queryformat () {
        return _("RPM information output format.");
    }

    public inline string option_sort () {
        return _("Sort the output in alphabetical order.");
    }

    public inline string option_asort () {
        return _("Sorts in the opposite direction of the `--sort' option.");
    }

    public inline string option_with_date () {
        return _("Show packages sorted by installation date.");
    }

    public inline string option_rpm () {
        return _("Show package names. Equal to `rpm -qa'");
    }

    public inline string option_files () {
        return _("Print package files.");
    }
}

namespace Apa.SearchFile.Descriptions {

    public inline string option_local () {
        return _("Search among the installed packages.");
    }

    public inline string option_short () {
        return _("To make the print more classic. Also removes the color selection.");
    }

    public inline string arg_option_branch () {
        return _("Which branch of the repository to use for the search. It is ignored if the `--installed' option is set. By default: `sisyphus'.");
    }

    public inline string arg_option_arch () {
        return _("In packages for which architecture to look for. It is ignored if the `--installed' option is set. Used current arch by default.");
    }
}

namespace Apa.Task.Descriptions {

    public inline string option_by_package () {
        return _("Find tasks by source package name.");
    }

    public inline string arg_option_owner () {
        return _("Task owner.");
    }

    public inline string arg_option_branch () {
        return _("Branch name.");
    }

    public inline string arg_option_state () {
        return _("Task state.");
    }
}

namespace Apa.UpdateKernel.Descriptions {

    public inline string option_force () {
        return AptGet.Descriptions.option_yes ();
    }

    public inline string option_download_only () {
        return AptGet.Descriptions.option_download_only ();
    }

    public inline string option_simulate () {
        return AptGet.Descriptions.option_simulate ();
    }

    public inline string option_header () {
        return _("Add kernel headers to install.");
    }

    public inline string option_all () {
        return _("Select all available kernel modules to install.");
    }

    public inline string option_interactive () {
        return _("Interactive modules selection.");
    }

    public inline string option_debuginfo () {
        return _("Add `-debuginfo' package to install.");
    }

    public inline string arg_option_add_module () {
        return _("Include (add) external module (by a short name).");
    }

    public inline string arg_option_del_module () {
        return _("Exclude (del) external module from install.");
    }

    public inline string arg_option_type () {
        return _("Select desired kernel flavour (def, rt, etc) by default it's the same as the booted kernel, special name `latest' selects the newest flavour.");
    }

    public inline string arg_option_release () {
        return _("Desired kernel release for the current or specified flavour (allowed formats by example: old format: alt1, 5.7.19-alt1; classic kernel release: 5.7.19-std-def-alt1; package name: [kernel-image-]std-def-5.7.19-alt1).");
    }
}
