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
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Apa {

    /*
     * Find the most similar straw in a haystack.
     *
     * Example:
     * "cor" -> { "car", "gog", "cert" } -> "car"
     *
     * @param haystack   The string in which to find
     * @param straw      The string that need to find something similar to
     *
     * @return           Similar straw in haystack
     */
    public string[]? find_best (string[] haystack, string straw) {
        var results = new string[3];
        int[] last_similaritys = { -10000, -10000, -10000 };
        var straw_chars = (char[]) straw.down ().data;
        int k = (int) (straw.length * 1.5);

        foreach (string str in haystack) {
            var str_chars = (char[]) str.dup ().down ().data;
            int similarity = 0;
            int similarity_diff = -1;

            for (int straw_i = 0; straw_i < straw_chars.length; straw_i++) {
                if (straw_chars[straw_i] == '-') {
                    continue;
                }

                for (int str_i = 0; str_i < str_chars.length; str_i++) {
                    if (str_chars[str_i] == '-') {
                        continue;
                    }

                    if (straw_chars[straw_i] == str_chars[str_i]) {
                        if (similarity_diff == -1) {
                            (str_i - straw_i).abs ();
                        }

                        similarity++;
                        similarity -= (straw_i - str_i).abs () - similarity_diff; 
                        str_chars[str_i] = '-';
                        break;
                    }
                }
            }

            if (str.length > k) {
                similarity -= (str.length - k) / (k - straw.length);
            } else {
                similarity += (straw.length - str.length - (k - straw.length)) / (k - straw.length);
            }

            print_devel ("%s : %i\n".printf (str, similarity));

            if (similarity > last_similaritys[0]) {
                if (last_similaritys[0] > last_similaritys[1]) {
                    if (last_similaritys[1] > last_similaritys[2]) {
                        last_similaritys[2] = last_similaritys[1];
                        results[2] = results[1];
                    }

                    last_similaritys[1] = last_similaritys[0];
                    results[1] = results[0];
                }

                last_similaritys[0] = similarity;
                results[0] = str;

            } else if (similarity > last_similaritys[1]) {
                if (last_similaritys[1] > last_similaritys[2]) {
                    last_similaritys[2] = last_similaritys[1];
                    results[2] = results[1];
                }

                last_similaritys[1] = similarity;
                results[1] = str;

            } else if (similarity > last_similaritys[2]) {
                last_similaritys[2] = similarity;
                results[2] = str;
            }
        }

        return results[0] == "" && results[1] == "" && results[2] == "" ? null : results;
    }

    /*
     * Meke every array string shorter.
     *
     * Example:
     * "package_name - Cool package" -> "package_name"
     *
     * @param array array with str to short
     */
    public void do_short_array (Array<string> array) {
        do_short (ref array.data);
    }

    public void do_short (ref string[] strs) {
        for (int i = 0; i < strs.length; i++) {
            strs[i] = make_string_short (strs[i]);
        }
    }

    internal string make_string_short (string str) {
        uint output_length = 0;
        var str_chars = (char[]) str.data;

        foreach (char c in str_chars) {
            if (c == ' ') {
                break;
            }

            output_length++;
        }

        var output = new char[output_length];

        for (int i = 0; i < output_length; i++) {
            output[i] = str_chars[i];
        }

        return (string) output;
    }
}
