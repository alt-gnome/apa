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

    public string option_package_cache () {
        return NO_DESCRIPTION;
    }

    public string option_source_cache () {
        return NO_DESCRIPTION;
    }

    public string option_hide_progress () {
        return NO_DESCRIPTION;
    }

    public string option_important_only () {
        return NO_DESCRIPTION;
    }

    public string arg_option_option () {
        return _("APT option");
    }

    public string arg_option_names_only () {
        return _("Show only names on search");
    }

    public string arg_option_config () {
        return _("Path to APT config file");
    }

    public string config_auto_update () {
        return _("Run `apa update' automatically before some commands");
    }

    public string config_use_fuzzy_search () {
        return _("Use fuzzy search in case of unsuccessful search via `apa search'");
    }
}
