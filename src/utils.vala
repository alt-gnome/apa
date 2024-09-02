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

internal struct Apa.FindBestData {
    public string package_name;
    public int similarity;
}

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
    public string?[]? find_best (string[] strs, string original) {
        var pre_results = new Array<FindBestData> ();
        var original_chars = (char[]) original.down ().data;

        foreach (string str in strs) {
            var str_chars = (char[]) str.down ().data;
            int similarity = 0;
            int comp_offset = -1;

            int original_i = 0;
            int str_i = 0;

            for (original_i = 0; original_i < original_chars.length; original_i++) {
                for (str_i = comp_offset == -1 ? 0 : comp_offset + original_i; str_i < str_chars.length; str_i++) {
                    if (original_chars[original_i] == str_chars[str_i]) {
                        int _comp_offset = (str_i - original_i).abs ();

                        if (comp_offset == -1) { 
                            similarity += _comp_offset;
                        }

                        comp_offset = _comp_offset;

                        similarity++;

                        str_chars[str_i] = ' ';
                        break;

                    } else {
                        similarity--;
                    }
                }
            }

            pre_results.append_val ({str, similarity});
        }

        pre_results.sort ((a, b) => {
            return (int) (a.similarity < b.similarity) - (int) (a.similarity > b.similarity);
        });

        if (pre_results.length == 0) {
            return null;
        }

        string?[] results = { null, null, null };

        for (int i = 0; i < results.length; i++) {
            if (pre_results.length < i + 1) {
                break;
            }

            if (pre_results.index (i).similarity > 0) {
                results[i] = pre_results.index (i).package_name;

            } else {
                break;
            }
        }
        
        return results;
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

    public bool is_root () {
        string output;
        string error;

        try {
            Process.spawn_sync (
                null,
                { "id", "-u" },
                null,
                SpawnFlags.SEARCH_PATH,
                null,
                out output,
                out error,
                null
            );

        } catch (SpawnError e) {
            GLib.error (e.message);
        }

        output = output.strip ();

        int output_int;
        if (int.try_parse (output, out output_int)) {
            return output_int == 0;
        }

        return false;
    }
}
