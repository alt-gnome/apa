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

public errordomain Apa.SearchFileRepoPatternError {
    NOT_AT_LEAST,
    WRONG_SYMBOL,
}

public errordomain Apa.CommandError {
    COMMON,
    UNKNOWN_SUBCOMMAND,
    TOO_MANY_ARGS,
    TOO_FEW_ARGS,
    UNKNOWN_ERROR,
    INVALID_TASK_ID,
    NO_PACKAGES_LEFT,
    TASK_IS_UNKNOWN,
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

public struct Apa.PackageSearchInfo {
    public string name;
    public string? description;

    public static PackageSearchInfo from_string (string str) {
        var parts = str.split (" - ");

        return {
            name: parts[0].strip (),
            description: parts.length > 1 ? parts[1].strip () : null,
        };
    }

    public string to_string (string format = "%s - %s") {
        return format.printf (
            name,
            description != null ? this.description : ""
        );
    }
}

namespace Apa {

    public async int bebra (owned ArgsHandler args_handler) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError, OptionsError {
        return 050;
    }

    public string current_locale;

    public string? get_config_description (string key) {
        foreach (var info in Config.Data.possible_config_keys ()) {
            if (info.name == key) {
                return info.description;
            }
        }

        return null;
    }

    public string? cut_of_command (ref string[] argv) {
        string? command = peek_command (ref argv);

        if (command == null) {
            return null;
        }

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

    public string? peek_command (ref string[] argv) {
        if (argv.length == 0) {
            return null;
        }

        if (argv[0].has_prefix ("-")) {
            return null;
        }

        return argv[0];
    }

    public void print_version () {
        print ("%s %s".printf (
            ApaConfig.NAME,
            ApaConfig.VERSION
        ));
    }

    /*
     * Meke every array string shorter.
     *
     * Example:
     * "package_name - Cool package" -> "package_name"
     *
     * @param array array with str to short
     */
    public PackageSearchInfo[] parse_search (string[] array) {
        var res = new PackageSearchInfo[array.length];

        for (int i = 0; i < array.length; i++) {
            res[i] = PackageSearchInfo.from_string (array[i]);
        }

        return res;
    }

    public bool is_root () {
        var uid_str = simple_exec ({ "id", "-u" });

        if (uid_str == null) {
            return false;
        }

        int uid;
        if (int.try_parse (uid_str, out uid)) {
            return uid == 0;
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
            print (cyan_text ("\nDEBUG\n%s\n".printf (str)));
        }
    }

    public void print_error (string str) {
        print_err (red_text ("%s %s").printf (bold_text (_("Error:")), str));
    }

    public ChoiceResult give_choice (string[] variants, string action_name, out string? result = null) {
        result = null;

        if (variants.length == 0) {
            return ChoiceResult.EXIT;
        }

        print ("");
        // Translators: %s is 'to install', 'to remove' etc
        print (_("Choose package %s:").printf (action_name));

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
            string? input = stdin.read_line ();

            if (input == null) {
                input = "0";
                print ("");

            } else if (input.strip () == "") {
                input = "1";

            } else {
                input = input.strip ();
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

    public string fix_regex (string regex) {
        StringBuilder builder = new StringBuilder ();

        for (int i = 0; i < regex.length; i++) {
            char current = regex[i];

            if (current == '*') {
                if (i == 0) {
                    builder.append_c ('.');

                } else if (regex[i - 1] != '.') {
                    builder.append_c ('.');
                }
            }

            builder.append_c (current);
        }

        return builder.free_and_steal ();
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

    public string get_arch () {
        return simple_exec ({ "arch" }) ?? "";
    }

    public string? simple_exec (string[] cmd) {
        string stdout;
        string stderr;

        try {
            Process.spawn_sync (
                null,
                cmd.copy (),
                null,
                SpawnFlags.SEARCH_PATH,
                null,
                out stdout,
                out stderr,
                null
            );

        } catch (SpawnError e) {
            GLib.error (e.message);
        }

        print_devel ("Simple exec: `%s' -> `%s'".printf (string.joinv (" ", cmd), stdout));

        return stdout != null ? stdout.strip () : null;
    }

    public string mark_text (string str, string[] what_marks) {
        var new_str = str.dup ();

        foreach (var what_mark in what_marks) {
            new_str = new_str.replace (what_mark, bold_text (green_text (what_mark)));
        }

        return new_str;
    }

    public string red_text (string str) {
        return "%s%s%s".printf (Colors.FAIL, str, Colors.ENDC);
    }

    public string cyan_text (string str) {
        return "%s%s%s".printf (Colors.CYAN, str, Colors.ENDC);
    }

    public string green_text (string str) {
        return "%s%s%s".printf (Colors.OKGREEN, str, Colors.ENDC);
    }

    public string bold_text (string str) {
        return "%s%s%s".printf (Colors.BOLD, str, Colors.ENDC);
    }

    public bool file_exists (string filepath) {
        return File.new_for_path (filepath).query_exists ();
    }

    /**
     * Repo regex pattern: `^[\w\/\.\+\- $#%:=@{}]{3,}$`
     */
    public void check_search_file_repo_arg (string arg) throws SearchFileRepoPatternError {
        if (arg.length < 3) {
            throw new SearchFileRepoPatternError.NOT_AT_LEAST ("3");
        }

        foreach (char c in (char[]) arg.data) {
            if ((Regex.match_simple ("\\w", c.to_string (), RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY))) {
                continue;
            }

            if ((c.to_string () in "/.+- $#%:=@{}")) {
                continue;
            }

            if (c.isalpha ()) {
                continue;
            }

            throw new SearchFileRepoPatternError.WRONG_SYMBOL (c.to_string ());
        }
    }
}
