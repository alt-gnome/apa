/*
 * Copyright (C) 2024 Vladimir Vaskov
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
public sealed class Apa.ConfigManager : Object {

    const string GROUP_NAME = "settings";

    static ConfigManager instance;

    public bool auto_update {
        get {
            return get_boolean (Config.Data.AUTO_UPDATE);
        }
        set {
            set_boolean (Config.Data.AUTO_UPDATE, value);
        }
    }

    public bool use_fuzzy_search {
        get {
            return get_boolean (Config.Data.USE_FUZZY_SEARCH);
        }
        set {
            set_boolean (Config.Data.USE_FUZZY_SEARCH, value);
        }
    }

    File default_config_file = File.new_build_filename (ApaConfig.KEY_DEFAULTS_DIR, "defaults");

    File _editable_config_file = File.new_build_filename (ApaConfig.KEY_DEFAULTS_DIR, "apa.conf");
    public File editable_config_file {
        get {
            try {
                if (is_root ()) {
                    if (!_editable_config_file.query_exists ()) {
                        _editable_config_file.create (GLib.FileCreateFlags.PRIVATE);
                        FileUtils.set_contents (_editable_config_file.peek_path (), "[settings]\n");
                    }
                } else {
                    var tmp_config_file = File.new_build_filename (Environment.get_tmp_dir (), "apa-tmp-file");
                    if (_editable_config_file.query_exists ()) {
                        _editable_config_file.copy (tmp_config_file, FileCopyFlags.OVERWRITE);
                    } else {
                        default_config_file.copy (tmp_config_file, FileCopyFlags.OVERWRITE);
                    }
                    _editable_config_file = tmp_config_file;
                }

            } catch (Error e) {
                print_error (e.message);
                Process.exit (ExitCode.BASE_ERROR);
            }

            return _editable_config_file;
        }
    }

    KeyFile key_file = new KeyFile ();
    KeyFile system_key_file = new KeyFile ();

    construct {
        update_configs ();
    }

    public static ConfigManager get_default () {
        if (instance == null) {
            instance = new ConfigManager ();
        }

        return instance;
    }

    void update_configs () {
        try {
            key_file.load_from_file (editable_config_file.peek_path (), GLib.KeyFileFlags.KEEP_COMMENTS);
            system_key_file.load_from_file (default_config_file.peek_path (), GLib.KeyFileFlags.KEEP_COMMENTS);

            foreach (var key in system_key_file.get_keys (GROUP_NAME)) {
                if (!key_file.has_key (GROUP_NAME, key)) {
                    key_file.set_value (GROUP_NAME, key, system_key_file.get_value (GROUP_NAME, key));
                }
            }

            key_file.save_to_file (editable_config_file.peek_path ());
            key_file.load_from_file (editable_config_file.peek_path (), GLib.KeyFileFlags.KEEP_COMMENTS);

        } catch (KeyFileError e) {
            resolve_key_file_error (e);
        } catch (FileError e) {
            resolve_file_error (e);
        }
    }

    void recreate_editable_config () {
        FileUtils.remove (editable_config_file.peek_path ());
        update_configs ();
    }

    void resolve_file_error (FileError e) {
        print_error (_("Couldn't open configuration file: %s").printf (e.message));
        Process.exit (ExitCode.BASE_ERROR);
    }

    void resolve_key_file_error (KeyFileError e) {
        print_error (_("Error in config: `%s'.\nRecreating…").printf (e.message));
        recreate_editable_config ();

        Process.exit (ExitCode.BASE_ERROR);
    }

    public bool has_key (string key) {
        try {
            return system_key_file.has_key (GROUP_NAME, key);
        } catch (KeyFileError e) {
            resolve_key_file_error (e);
        }
        return false;
    }

    public void reset (string key) {
        try {
            if (has_key (key)) {
                set_value (key, system_key_file.get_value (GROUP_NAME, key));
            }
        } catch (KeyFileError e) {
            resolve_key_file_error (e);
        }
    }

    public void reset_all () {
        foreach (var info in Config.Data.possible_config_keys ()) {
            reset (info.name);
        }
    }

    public string get_value (string key) {
        try {
            if (!key_file.has_key (GROUP_NAME, key)) {
                if (has_key (key)) {
                    return system_key_file.get_value (GROUP_NAME, key);
                } else {
                    print_error (_("Key `%s' doesn't exists").printf (key));
                    Process.exit (ExitCode.BASE_ERROR);
                }
            }

            return key_file.get_value (GROUP_NAME, key);
        } catch (KeyFileError e) {
            resolve_key_file_error (e);
        }
        return "";
    }

    public void set_value (string key, string value) {
        if (!has_key (key)) {
            print_error (_("Key `%s' doesn't exists").printf (key));
            Process.exit (ExitCode.BASE_ERROR);
        }

        if (detect_type (value) != detect_type (get_value (key))) {
            wrong_type (detect_type (get_value (key)));
        }

        try {
            key_file.set_value (GROUP_NAME, key, value);
            key_file.save_to_file (editable_config_file.peek_path ());
        } catch (FileError e) {
            resolve_file_error (e);
        }
    }

    public bool get_boolean (string key) {
        try {
            return key_file.get_boolean (GROUP_NAME, key);
        } catch (KeyFileError e) {
            resolve_key_file_error (e);
            return false;
        }
    }

    public void set_boolean (string key, bool value) {
        set_value (key, value.to_string ());
    }

    public string get_string (string key) {
        try {
            return key_file.get_string (GROUP_NAME, key);
        } catch (KeyFileError e) {
            resolve_key_file_error (e);
            return "";
        }
    }

    public void set_string (string key, string value) {
        set_value (key, value);
    }

    public Type detect_config_type (string key) {
        if (!has_key (key)) {
            return Type.NONE;
        }

        var value = get_value (key);

        return detect_type (value);
    }

    void wrong_type (Type possible_type) {
        string expected;

        switch (possible_type) {
            case Type.BOOLEAN:
                expected = "`true' or `false'";
                break;

            case Type.STRING:
                expected = "string";
                break;

            case Type.INT:
                expected = "number";
                break;

            default:
                return;
        }

        print_error (_("Wrong config type. Expected %s").printf (expected));
        Process.exit (ExitCode.BASE_ERROR);
    }
}
