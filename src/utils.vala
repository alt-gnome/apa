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

public struct Apa.ArgOption {

    public string name;
    public string value;

    public static ArgOption from_string (string str) {
        int delim_index = -1;

        for (int i = 0; i < str.length; i++) {
            if (str[i] == '=') {
                delim_index = i;
                break;
            }
        }

        if (delim_index == -1) {
            return { name: str, value: "" };

        } else {
            return { name: str[0:delim_index], value: str[delim_index + 1:str.length] };
        }
    }

    public static bool equal_func (ArgOption? a, ArgOption? b) {
        return a?.name == b?.name && a?.value == b?.value;
    }
}

public struct Apa.ConfigInfo {

    public string name;
    public DescriptionGetter description_getter;
}

public struct Apa.OptionData {

    public string short_option;
    public string long_option;
    public string target_option;
    public DescriptionGetter description_getter;

    public bool contain (string option) {
        return option == short_option || option == long_option;
    }

    public static OptionData[] concat (OptionData[] arr1, OptionData[] arr2) {
        OptionData[] new_arr = new OptionData[arr1.length + arr2.length];

        for (int i = 0; i < arr1.length; i++) {
            new_arr[i] = arr1[i];
        }

        for (int i = arr1.length; i < new_arr.length; i++) {
            new_arr[i] = arr2[i - arr1.length];
        }

        return new_arr;
    }

    public static OptionData? find_option (OptionData[] options, string option) {
        foreach (var opt in options) {
            if (opt.short_option == option || opt.long_option == option) {
                return opt;
            }
        }

        return null;
    }
}

public errordomain Apa.CommandError {
    COMMON,
    UNKNOWN_SUBCOMMAND,
    TO_MANY_ARGS,
    NO_PACKAGES,
    CANT_UPDATE,
    CANT_UPDATE_KERNEL,
    UNKNOWN_ERROR,
    INVALID_TASK_ID,
    NO_PACKAGES_LEFT,
}

public errordomain Apa.OptionsError {
    UNKNOWN_OPTION,
    UNKNOWN_ARG_OPTION,
    NO_ARG_OPTION_VALUE,
}

public enum Apa.ChoiceResult {
    SKIP,
    CHOSEN,
    EXIT,
}

namespace Apa {

    public delegate string DescriptionGetter ();

    public string current_locale;

    public string? get_config_description (string key) {
        foreach (var info in Config.Data.POSSIBLE_CONFIG_KEYS) {
            if (info.name == key) {
                return info.description_getter ();
            }
        }

        return null;
    }

    public Type detect_type (string str) {
        if (bool.try_parse (str, null)) {
            return Type.BOOLEAN;

        } else if (int.try_parse (str, null)) {
            return Type.INT;

        } else {
            return Type.STRING;
        }
    }

    public string? cut_of_command (ref string[] argv) {
        if (argv.length == 0) {
            return null;
        }

        if (argv[0].has_prefix ("-")) {
            return null;
        }

        string command = argv[0];

        if (argv.length == 1) {
            argv = {};

        } else {
            for (int i = 0; i < argv.length - 1; i++) {
                argv[i] = argv[i + 1];
            }

            argv.resize (argv.length - 1);
        }

        return command;
    }

    public string get_version () {
        return "%s %s".printf (
            ApaConfig.NAME,
            ApaConfig.VERSION
        );
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
                current_locale = lang;
                return true;
            }
        }

        return false;
    }

    public void print (string str, bool with_return = true) {
        stdout.puts (str);
        if (with_return) {
            stdout.putc ('\n');
        }
        stdout.flush ();
    }

    public void print_err (string str) {
        stderr.puts (str);
        stderr.putc ('\n');
        stderr.flush ();
    }

    public void print_devel (string str) {
        if (ApaConfig.IS_DEVEL) {
            print ("\n%sDEBUG\n%s%s\n".printf (
                Colors.CYAN,
                str,
                Colors.ENDC
            ));
        }
    }

    public void print_error (string str) {
        print_err ("%sE: %s %s".printf (
            Colors.FAIL,
            str,
            Colors.ENDC
        ));
    }

    public ChoiceResult give_choice (string[] variants, string action_name, out string? result = null) {
        result = null;

        if (variants.length == 0) {
            return ChoiceResult.CHOSEN;
        }

        print ("");
        print (_("Choose package to %s:").printf (action_name));

        for (int i = 0; i < variants.length; i++) {
            if (variants[i] != null) {
                if (i == 0) {
                    print ("\t*%i) %s".printf (i + 1, variants[i]));

                } else {
                    print ("\t %i) %s".printf (i + 1, variants[i]));
                }
            }
        }

        print ("");

        while (true) {
            // Translators: IMPORTANT! space symbol in the end
            print (_("[0 - exit; -1 - skip] "), false);
            var input = stdin.read_line ().strip ();

            if (input == "") {
                input = "1";
            }

            int input_int;
            if (int.try_parse (input, out input_int)) {
                if (input_int > 0 && input_int <= variants.length && variants[input_int - 1] != null) {
                    result = variants[input_int - 1];
                    return ChoiceResult.CHOSEN;

                } else if (input_int == -1) {
                    return ChoiceResult.SKIP;

                } else if (input_int == 0) {
                    return ChoiceResult.EXIT;
                }
            }
        }
    }

    public string find_package_in_do_list (Gee.ArrayList<string> do_list, string package) {
        foreach (string do_package in do_list) {
            if (do_package.length == package.length + 1 && do_package.has_prefix (package)) {
                return do_package;
            }
        }

        print_devel ("%s\n%s".printf (package, string.joinv (", ", do_list.to_array ())));
        assert_not_reached ();
    }

    public void replace_strings_in_array_list (Gee.ArrayList<string> array, string old_string, string new_string) {
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

    public void print_create_issue (string error_message, string[] argv) {
        string body = "```%s```".printf (form_command (error_message, argv));

        print (_("You should %s").printf (
            "%s\033]8;;%s\033\\%s\033]8;;\033\\%s".printf (
                Colors.OKBLUE,
                "https://github.com/alt-gnome/apa/issues/new?label=%s&title=%s&body=%s".printf (
                    "unknown-error",
                    Uri.escape_string ("Unknown error: %s".printf (error_message), null, true),
                    Uri.escape_string (body, null, true)
                ),
                _("create issue↗️"),
                Colors.ENDC
            )
        ));
    }

    public async bool check_package_name_no_action (string package_name) {
        if (package_name.has_suffix ("-") || package_name.has_suffix ("+")) {
            if ((yield spawn_command_silence (new Gee.ArrayList<string>.wrap ({"rpm", "-q", package_name[0:package_name.length - 1]}), null)) == ExitCode.SUCCESS) {
                return false;
            }
        }

        return true;
    }

    public string form_command (string error_message, string[] argv) {
        return "\nError message quoted:\n\t\"%s\"\nLocale:\n\t%s\nCommand:\n\tapa %s\n".printf (
            error_message,
            current_locale,
            string.joinv (" ", argv)
        );
    }

    public bool pk_is_running () throws Error {
        var ch = new Pk.Control ();
        return ch.get_transaction_list ().length > 0;
    }
}
