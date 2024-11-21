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

struct VazzyData {
    public string str;
    public int distance;
}

namespace Apa {

    const int INSERT_COST = 1;
    const int DELETE_COST = 1;
    const int REPLACE_COST = 1;
    const int SWAP_COST = 1;

    const string[] KNOWN_PREFIXES = {
        "",
        "python3-module-",
    };

    /*
     * Find the most similar string in a strings.
     *
     * Example:
     * "cor" -> { "car", "gog", "cert" } -> { "car", null, null }
     *
     * @param query The string that need to find something similar to
     * @param data  The strings in which to find
     *
     * @return      Similar query in data
     */
    public string?[]? fuzzy_search (string query, string[] data) {
        string aquery = query.replace ("-", "").down ();

        foreach (string str in data) {
            foreach (string prefix in KNOWN_PREFIXES) {
                if (str.replace ("-", "").down () == prefix + aquery) {
                    return { str, null, null };
                }
            }
        }

        var pre_results = new Gee.ArrayList<VazzyData?> ();
        foreach (var str in data) {
            string astr = str.replace ("-", "").down ();

            var distance = Vazzy.compute_damerau_levenshtein_distance (aquery, astr, INSERT_COST, DELETE_COST, REPLACE_COST, SWAP_COST);

            if (aquery in astr) {
                distance -= aquery.length;
            }

            pre_results.add ({
                str,
                distance
            });

            print_devel (aquery + " -> " + str + ": " + distance.to_string ());
        }

        pre_results.sort ((a, b) => {
            return (int) (a.distance > b.distance) - (int) (a.distance < b.distance);
        });

        if (pre_results.size == 0) {
            return null;
        }

        string?[] results = new string?[9];

        for (int i = 0; i < results.length && i < pre_results.size; i++) {
            if (pre_results[i].distance < aquery.length / 2) {
                results[i] = pre_results[i].str;

            } else {
                break;
            }
        }

        if (results[0] == null ) {
            return null;
        }

        return results;
    }
}
