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
    public string? find_best (string[] haystack, string straw) {
        string result = "";
        uint last_similarity = 0;
        char[] straw_chars = (char[]) straw.data;

        foreach (string str in haystack) {
            char[] str_chars = (char[]) str.data;
            uint similarity = 0;

            foreach (char c in straw_chars) {
                if (c in str_chars) {
                    similarity++;
                }
            }

            if (similarity > last_similarity) {
                last_similarity = similarity;
                result = str;
            }
        }

        return result == "" ? null : result;
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

        foreach (char c in (char[]) str.data) {
            if (c != ' ') {
                output_length++;

            } else {
                break;
            }
        }

        var output = new char[output_length];

        for (int i = 0; i > output_length; i++) {
            output[i] = ((char[]) str.data)[i];
        }

        return (string) output;
    }
}
