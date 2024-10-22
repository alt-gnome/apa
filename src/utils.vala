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
    UNABLE_TO_LOCK_DOWNLOAD_DIR,
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
            print ("Matches %s in %s".printf (query, str));
            foreach (var match in matchs) {
                print ("\t%s\t%d\t%d".printf (
                    (string) match.match_str.to_array (),
                    match.start_index,
                    match.similarity
                ));

                if (top_match == null) {
                    top_match = match;
                    continue;
                }

                if (top_match.similarity < match.similarity) {
                    top_match = match;
                }
            }
            print ("\n\n");

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

    public ErrorType detect_error (string error_message, out string package = null) {
        // Should be aligned with ErrorType enum
        string[] apt_errors = {
            "Couldn't find package %s",
            "Package %s is a virtual package with multiple good providers.\n",
            "Unable to lock the download directory"
        };

        string pattern;
        Regex regex;
        package = null;

        try {
            for (int i = 0; i < apt_errors.length; i++) {
                pattern = (dgettext (
                    "apt",
                    apt_errors[i]
                )).replace ("%s", "(.*)");

                regex = new Regex (
                    pattern,
                    RegexCompileFlags.OPTIMIZE,
                    RegexMatchFlags.NOTEMPTY
                );

                MatchInfo match_info;
                if (regex.match (error_message, 0, out match_info)) {
                    package = match_info.fetch (1);
                    return (ErrorType) i;

                } else {
                    print_devel ("\n%s\n%s\n".printf (apt_errors[i], pattern));
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

    public string? give_choice (string[] variants) {
        for (int i = 0; i < variants.length; i++) {
            if (variants[i] != null) {
                print ("\t%i) %s".printf (i + 1, variants[i]));
            }
        }

        print ("");

        while (true) {
            print (_("Choose which on to install: [1 by default, 0 to exit] "), false);
            var input = stdin.read_line ().strip ();

            if (input == "") {
                input = "1";
            }

            int input_int;
            if (int.try_parse (input, out input_int)) {
                if (input_int > 0 && input_int <= 3 && variants[input_int - 1] != null) {
                    return variants[input_int - 1];

                } else if (input_int == 0) {
                    return null;
                }
            }
        }
    }

    public void replace_strings_in_array (ref string[] array, string old_string, string new_string) {
        for (int i = 0; i < array.length; i++) {
            if (array[i] == old_string) {
                array[i] = new_string;
            }
        }
    }

    public void replace_strings_in_array_list (ref Gee.ArrayList<string> array, string old_string, string new_string) {
        for (int i = 0; i < array.size; i++) {
            if (array[i] == old_string) {
                array[i] = new_string;
            }
        }
    }

    public string[] split_chars (string str) {
        string[] result = new string[str.length];
        for (int i = 0; i < str.length; i++) {
            result[i] = str[i].to_string ();
        }
        return result;
    }

    public void print_issue () {
        print (_("You can create issue here https://github.com/alt-gnome/apa/issues"));
    }

    public bool pk_is_running () throws Error {
        var ch = new Pk.Control ();
        return ch.locked;
    }
}
