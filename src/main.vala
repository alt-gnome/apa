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

// ind-check=skip-file

public static int main (string[] argv) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bindtextdomain ("apt", Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.bind_textdomain_codeset ("apt", "UTF-8");

    if (!Apa.locale_init ()) {
        warning ("Locale not supported by C library.\n\tUsing the fallback `C' locale.");
    }

    Environment.set_prgname (Config.NAME);

    var fargv = argv[1:argv.length];

    int exit_status = 0;

    var loop = new MainLoop ();
    Apa.run.begin (fargv, (obj, res) => {
        exit_status = Apa.run.end (res);
        loop.quit ();
    });
    loop.run ();

    return exit_status;
}
