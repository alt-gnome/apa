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

struct Apa.FindBestData {
    public string package_name;
    public int similarity;
}

public struct Apa.OptionData {
    public string short_option;
    public string long_option;
    public string target_option;

    public bool contains (string option) {
        return option == short_option || option == long_option;
    }
}

public errordomain Apa.CommonCommandError {
    UNKNOWN_COMMAND,
    UNKNOWN_OPTION,
}

public errordomain Apa.CommandError {
    NO_PACKAGES
}

public enum Apa.ErrorType {
    COULDNT_FIND_PACKAGE,
    PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS,
    NONE,
}

namespace Apa {

    public string get_version () {
        return "%s %s".printf (
            Config.NAME,
            Config.VERSION
        );
    }

    public void set_options (
        ref Gee.ArrayList<string> spawn_arr,
        Gee.ArrayList<string> current_options,
        Gee.ArrayList<ArgOption?> current_arg_options,
        OptionData[] possible_options
    ) {
        var added_options = new Gee.ArrayList<string> ();
        var added_arg_options = new Gee.ArrayList<ArgOption?> ((el1, el2) => {
            return el1.name == el2.name && el1.value == el2.value;
        });

        foreach (var option in current_options) {
            foreach (var option_data in possible_options) {
                if (option in option_data) {
                    added_options.add (option);

                    spawn_arr.add (option_data.target_option);
                    break;
                }
            }
        }

        foreach (var option in current_arg_options) {
            foreach (var option_data in possible_options) {
                if (option.name in option_data) {
                    added_arg_options.add (option);

                    spawn_arr.add (option_data.target_option);
                    spawn_arr.add (option.value);
                    break;
                }
            }
        }

        current_options.remove_all (added_options);
        current_arg_options.remove_all (added_arg_options);
    }

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
    public string?[]? fuzzy_search (string query, string[] data) {
        var pre_results = new Gee.ArrayList<FindBestData?> ();
        var query_chars = (char[]) query.down ().data;

        foreach (string str in data) {
            var str_chars = (char[]) str.down ().data;
            int similarity = 0;
            int comp_offset = -1;

            int query_i = 0;
            int str_i = 0;

            for (query_i = 0; query_i < query_chars.length; query_i++) {
                for (str_i = comp_offset == -1 ? 0 : comp_offset + query_i; str_i < str_chars.length; str_i++) {
                    if (query_chars[query_i] == str_chars[str_i]) {
                        int _comp_offset = (str_i - query_i).abs ();

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

            pre_results.add ({str, similarity});
        }

        pre_results.sort ((a, b) => {
            return (int) (a.similarity < b.similarity) - (int) (a.similarity > b.similarity);
        });

        if (pre_results.size == 0) {
            return null;
        }

        string?[] results = { null, null, null };

        for (int i = 0; i < results.length; i++) {
            if (pre_results.size < i + 1) {
                break;
            }

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

    /*
     * Meke every array string shorter.
     *
     * Example:
     * "package_name - Cool package" -> "package_name"
     *
     * @param array array with str to short
     */
    public void do_short_array_list (ref Gee.ArrayList<string> array) {
        for (int i = 0; i < array.size; i++) {
            array[i] = do_short (array[i]);
        }
    }

    public void do_short_data (ref string[] data) {
        for (int i = 0; i < data.length; i++) {
            data[i] = do_short (data[i]);
        }
    }

    public string do_short (string str) {
        return str.split (" ")[0];
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

    public bool locale_init () {
        foreach (string lang in Intl.get_language_names ()) {
            if (Intl.setlocale (LocaleCategory.ALL, lang) != null) {
                return true;
            }
        }

        return false;
    }

    public bool has_internet_connection () {
        int status_code;

        try {
            Process.spawn_sync (
                null,
                { "ping", "ya.ru", "-c", "1" },
                null,
                SpawnFlags.SEARCH_PATH | SpawnFlags.STDOUT_TO_DEV_NULL | SpawnFlags.STDERR_TO_DEV_NULL,
                null,
                null,
                null,
                out status_code
            );

        } catch (SpawnError e) {
            GLib.error (e.message);
        }

        if (status_code == 0) {
            return true;

        } else {
            return false;
        }
    }

    public ErrorType detect_error (string error_message) {
        // Should be aligned with ErrorType enum
        string[] apt_error = {
            "Couldn't find package %s",
            "Package %s is a virtual package with multiple good providers.\n",
        };

        try {
            string pattern;
            Regex regex;

            for (int i = 0; i < apt_error.length; i++) {
                pattern = (dgettext (
                    "apt",
                    apt_error[i]
                )).replace ("%s", ".*");

                regex = new Regex (
                    pattern,
                    RegexCompileFlags.OPTIMIZE,
                    RegexMatchFlags.NOTEMPTY
                );

                if (regex.match (error_message, 0, null)) {
                    return (ErrorType) i;
                }
            }

        } catch (Error e) {
            print_error (e.message);
        }

        return NONE;
    }

    public string normalize_error (Gee.ArrayList<string> error) {
        string error_message = "";

        for (int i = error.size - 1; i >= 0; i--) {
            if (error[i].strip () != "") {
                error_message = error[i].replace ("E: ", "");
                error.remove_at (i);
                break;

            } else {
                error.remove_at (i);
            }
        }

        for (int i = 0; i < error.size; i++) {
            if (error[i][error[i].length - 1] == '\n') {
                error[i] = error[i][0:error[i].length - 1];
            }
        }

        return error_message;
    }

    public void print (string str, bool with_return = true) {
        stdout.puts (str);
        if (with_return) {
            stdout.putc ('\n');
        }
        stdout.flush ();
    }

    internal void print_err (string str) {
        stderr.puts (str);
        stderr.putc ('\n');
        stderr.flush ();
    }

    public void print_devel (string str) {
        if (Config.IS_DEVEL) {
            print ("\n%sDEBUG\n%s%s\n".printf (
                Constants.Colors.CYAN,
                str,
                Constants.Colors.ENDC
            ));
        }
    }

    public void print_error (string str) {
        print_err ("%sE: %s %s".printf (
            Constants.Colors.FAIL,
            str,
            Constants.Colors.ENDC
        ));
    }
}
