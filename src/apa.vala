/*
 * Copyright 2024 Rirusha
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
 * SPDX-License-Identifier: GPL-3.0-only
 */



namespace Apa {

    internal static bool version = false;

    const OptionEntry[] OPTION_ENTRIES = {
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref version, N_("Print version information and exit"), null },
        { null }
    };

    internal OptionContext option_context;

    public static int run (string[] args) {
        option_context = new OptionContext ("- apa install libgio-devel");

        option_context.add_main_entries (OPTION_ENTRIES, Config.GETTEXT_PACKAGE);
        option_context.set_summary ("ALT Packages Assistant");

        try {
            option_context.parse (ref args);

        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
            return 1;
        }

        if (version) {
            print ("%s %s\n".printf (
                Config.NAME,
                Config.VERSION
            ));
			return 0;
        }

        return 0;
    }
}
