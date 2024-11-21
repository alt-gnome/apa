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

public struct Apa.OptionData {
    public string short_option;
    public string long_option;
    public string target_option;

    public bool contains (string option) {
        return option == short_option || option == long_option;
    }
}

public errordomain Apa.CommandError {
    UNKNOWN_COMMAND,
    TO_MANY_ARGS,
    UNKNOWN_OPTION,
    NO_PACKAGES,
    CANT_UPDATE,
    CANT_UPDATE_KERNEL,
}

public enum Apa.ChoiceResult {
    SKIP,
    CHOSEN,
    EXIT,
}

namespace Apa {

    public string current_locale;

    public const string SKIP_PACKAGE_SENTENCE = _("<skip package>");

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

    public void print_create_issue (string error_message, CommandHandler command_handler) {
        string body = "```%s```".printf (form_command (error_message, command_handler));

        print (_("You should %s").printf (
            "%s\033]8;;%s\033\\%s\033]8;;\033\\%s".printf (
                Constants.Colors.OKBLUE,
                "https://github.com/alt-gnome/apa/issues/new?label=%s&title=%s&body=%s".printf (
                    "unknown-error",
                    Uri.escape_string ("Unknown error: %s".printf (error_message), null, true),
                    Uri.escape_string (body, null, true)
                ),
                _("create issue↗️"),
                Constants.Colors.ENDC
            )
        ));
    }

    public async bool check_package_name_no_action (string package_name) {
        if (package_name.has_suffix ("-") || package_name.has_suffix ("+")) {
            if ((yield spawn_command_silence (new Gee.ArrayList<string>.wrap ({"rpm", "-q", package_name[0:package_name.length - 1]}), null)) == Constants.ExitCode.SUCCESS) {
                return false;
            }
        }

        return true;
    }

    public string form_command (string error_message, CommandHandler command_handler) {
        string command = command_handler.command;

        if (command_handler is SubCommandHandler) {
            command += " " + ((SubCommandHandler) command_handler).subcommand;
        }

        var argo = new string[command_handler.arg_options.size];
        for (int i = 0; i < command_handler.arg_options.size; i++) {
            argo[i] = "%s=%s".printf (command_handler.arg_options[i].name, command_handler.arg_options[i].value);
        }

        return "\nError message quoted:\n\"%s\"\nLocale: %s\nCommand: %s\nArgs: %s\nOptions: %s\nArguments options: %s\n".printf (
            error_message,
            current_locale,
            command,
            string.joinv (" ", command_handler.options.to_array ()),
            string.joinv (" ", argo),
            string.joinv (" ", command_handler.argv.to_array ())
        );
    }

    public bool pk_is_running () throws Error {
        var ch = new Pk.Control ();
        return ch.get_transaction_list ().length > 0;
    }
}
