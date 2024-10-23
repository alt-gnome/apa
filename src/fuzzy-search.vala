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

struct FindBestData {
    public string package_name;
    public int similarity;
}

sealed class MatchData {

    public string query_string;
    public string origin_string;
    public int start_index;
    public Gee.ArrayList<char> match_str;
    public int similarity = 4;
    public int offset;
    public int last_s_i = -1;

    public MatchData (
        string query_string,
        string origin_string,
        int start_index,
        char first_char
    ) {
        this.query_string = query_string;
        this.origin_string = origin_string;
        this.start_index = start_index;
        this.match_str = new Gee.ArrayList<char>.wrap ({ first_char });
        this.offset = 0;
    }

    public bool try_add (int index, char c) {
        if (index == match_str.size + start_index + offset && c == origin_string[index] && last_s_i < index) {
            last_s_i = index;

            match_str.add (c);
            similarity += 2;
            return true;

        } else if (c == origin_string[index] && index > match_str.size + start_index + offset && last_s_i < index) {
            last_s_i = index;

            offset = index - match_str.size - start_index;

            match_str.add (c);
            similarity += 2;
            return true;

        }

        return false;
    }

    public void close () {
        similarity -= start_index + (origin_string.length - start_index - match_str.size - offset) + offset * 2;
    }
}

namespace Apa {

    /*
     * Find the most similar straw in a haystack.
     *
     * Example:
     * "cor" -> { "car", "gog", "cert" } -> { "car", null, null }
     *
     * @param haystack   The string in which to find
     * @param straw      The string that need to find something similar to
     *
     * @return           Similar straw in haystack
     */
    public string?[]? fuzzy_search (string query, string[] data) {
        var pre_results = new Gee.ArrayList<FindBestData?> ();
        // query internal
        string q_in = query.down ();

        foreach (string str in data) {
            // str internal
            string s_in = str.down ();

            int q_i = 0;
            int s_i = 0;

            var matchs = new Gee.ArrayList<MatchData?> ();
            var matchs_used = new Gee.ArrayList<MatchData?> ((el1, el2) => {
                return el1.start_index == el2.start_index;
            });

            for (q_i = 0; q_i < q_in.length; q_i++) {
                char q_in_c = q_in[q_i];

                matchs_used.clear ();

                for (s_i = 0; s_i < s_in.length; s_i++) {
                    char s_in_c = s_in[s_i];

                    bool added = false;
                    foreach (var match in matchs) {
                        if (match in matchs_used) {
                            continue;
                        }

                        added = match.try_add (s_i, q_in_c);

                        if (added) {
                            matchs_used.add (match);
                        }
                    }

                    if (!added && s_in_c == q_in_c) {
                        matchs.insert (0, new MatchData (
                            query,
                            s_in,
                            s_i,
                            s_in_c
                        ));

                        matchs_used.add (matchs[0]);
                    }
                }
            }

            foreach (var match in matchs) {
                match.close ();
            }

            MatchData? top_match = null;
            foreach (var match in matchs) {
                if (top_match == null) {
                    top_match = match;
                    continue;
                }

                if (top_match.similarity < match.similarity) {
                    top_match = match;
                }
            }

            if (top_match != null) {
                pre_results.add ({str, top_match.similarity});
            }
        }

        pre_results.sort ((a, b) => {
            return (int) (a.similarity < b.similarity) - (int) (a.similarity > b.similarity);
        });

        if (pre_results.size == 0) {
            return null;
        }

        string?[] results = { null, null, null };

        for (int i = 0; i < results.length && i < pre_results.size; i++) {
            if (pre_results[i].similarity > 0) {
                results[i] = pre_results[i].package_name;

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
