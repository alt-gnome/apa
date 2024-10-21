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

namespace Apa.Moo {

    public string get_moo (string? phrase = null) {
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
,-"~`-._ `"--'_   `"\""`  _ \`'"~-,_
\       `-.  '_`.      .'_` \ ,-"~`/
 `.__.-'`/   (-\        /-) |-.__,'
   ||   |     \O)  /^\ (O/  |
   `\\  |         /   `\    /
     \\  \       /      `\ /
      `\\ `-.  /' .---.--.\
        `\\/`~(, '()      ('
         /(O) \\   _,.-.,_)    < "%s"
        //  \\ `\'`      /
  jgs  / |  ||   `""\""~"`
     /'  |__||
           `o

Art by Joan Stark
""";

    string[] get_phrases () {
        return {
            _("With great moower comes great resmoonsibility"),
            _("I am your Moother"),
            _("I use ALT btw…"),
        };
    }
}
