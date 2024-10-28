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
    internal int moo (CommandArgs ca) {
        if (ca.command_argv.length > 0) {
            print (get_moo (ca.command_argv[0]), false);

        } else {
            print (get_moo (), false);
        }

        return Constants.ExitCode.SUCCESS;
    }

    string get_moo (string? phrase = null) {
        if (phrase != null) {
            return MOO.printf (phrase);

        } else {
            var phrases = get_phrases ();
            return MOO.printf (phrases[Random.int_range (0, phrases.length)]);
        }
    }

    const string MOO =
"""
          .=     ,        =.
  _  _   /'/    )\,/,/(_   \ \
   `//-.|  (  ,\\)\//\)\/_  ) |
   //___\   `\\\/\\/\/\\///'  /
,-"~`-._ `"--'_   `"'"`  _ \`'"~-,_
\       `-.  '_`.      .'_` \ ,-"~`/
 `.__.-'`/   (-\        /-) |-.__,'
   ||   |     \O)  /^\ (O/  |
   `\\  |         /   `\    /
     \\  \       /      `\ /
      `\\ `-.  /' .---.--.\
        `\\/`~(, '()      ('
         /(O) \\   _,.-.,_)    < "%s"
        //  \\ `\'`      /
  jgs  / |  ||   `""'"~"`
     /'  |__||
           `o

Art by Joan Stark
""";

    string[] get_phrases () {
        return {
            _("With great moower comes great resmoonsibility"),
            _("I am your Moother"),
            _("I use ALT btw…"),
            _("Have you mooed today?"),
        };
    }
}
