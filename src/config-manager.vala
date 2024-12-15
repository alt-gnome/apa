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

    File? _editable_config_file = File.new_build_filename (ApaConfig.KEY_DEFAULTS_DIR, "apa.conf");
    File? editable_config_file {
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
                        _editable_config_file = tmp_config_file;
                    } else {
                        _editable_config_file = null;
                    }
                }

            } catch (Error e) {
                print_error (e.message);
                Process.exit (ExitCode.BASE_ERROR);
            }

            return _editable_config_file;
        }
    }

    KeyFile? key_file = null;

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
        if (editable_config_file == null) {
            return;
        }

        if (key_file == null) {
            key_file = new KeyFile ();
        }

        try {
            key_file.load_from_file (editable_config_file.peek_path (), GLib.KeyFileFlags.KEEP_COMMENTS);

            foreach (var key in Config.Data.possible_config_keys ()) {
                if (!key_file.has_key (GROUP_NAME, key.name)) {
                    key_file.set_value (GROUP_NAME, key.name, key.default_value);
                }
            }

            key_file.save_to_file (editable_config_file.peek_path ());
            key_file.load_from_file (editable_config_file.peek_path (), GLib.KeyFileFlags.KEEP_COMMENTS);

        } catch (KeyFileError e) {
            resolve_key_file_error ();
        } catch (FileError e) {
            resolve_file_error ();
        }
    }

    void recreate_editable_config () {
        if (editable_config_file == null) {
            return;
        }

        FileUtils.remove (editable_config_file.peek_path ());
        update_configs ();
    }

    void resolve_file_error () {
        print_error (_("Couldn't open configuration file."));
        Process.exit (ExitCode.BASE_ERROR);
    }

    void resolve_key_file_error () {
        print_error (_("Error in config. Recreating…"));
        recreate_editable_config ();

        Process.exit (ExitCode.BASE_ERROR);
    }

    public bool has_key (string key) {
        return ConfigEntity.find (Config.Data.possible_config_keys (), key) != null;
    }

    public void reset (string key) {
        if (has_key (key)) {
            set_value (key, ConfigEntity.find (Config.Data.possible_config_keys (), key).default_value);

        } else {
            print_error (_("Key `%s' doesn't exists").printf (key));
            Process.exit (ExitCode.BASE_ERROR);
        }
    }

    public void reset_all () {
        foreach (var info in Config.Data.possible_config_keys ()) {
            reset (info.name);
        }
    }

    public string get_value (string key) {
        var config_entity = ConfigEntity.find (Config.Data.possible_config_keys (), key);

        if (key_file == null) {
            if (config_entity != null) {
                return config_entity.default_value;

            } else {
                print_error (_("Key `%s' doesn't exists").printf (key));
                Process.exit (ExitCode.BASE_ERROR);
            }
        }

        try {
            if (!key_file.has_key (GROUP_NAME, key)) {
                if (config_entity != null) {
                    return config_entity.default_value;

                } else {
                    print_error (_("Key `%s' doesn't exists").printf (key));
                    Process.exit (ExitCode.BASE_ERROR);
                }
            }

            return key_file.get_value (GROUP_NAME, key);
        } catch (KeyFileError e) {
            resolve_key_file_error ();
        }
        return "";
    }

    public void set_value (string key, string value) {
        if (key_file == null) {
            return;
        }

        var config_entity = ConfigEntity.find (Config.Data.possible_config_keys (), key);

        if (config_entity == null) {
            print_error (_("Key `%s' doesn't exists").printf (key));
            Process.exit (ExitCode.BASE_ERROR);
        }

        if (!Regex.match_simple (
            config_entity.possible_values_pattern,
            value,
            RegexCompileFlags.OPTIMIZE,
            RegexMatchFlags.NOTEMPTY
        )) {
            print_error (_("Wrong type."));
            Process.exit (ExitCode.BASE_ERROR);
        }

        try {
            key_file.set_value (GROUP_NAME, key, value);
            key_file.save_to_file (editable_config_file.peek_path ());
        } catch (FileError e) {
            resolve_file_error ();
        }
    }

    public bool get_boolean (string key) {
        bool res;

        if (bool.try_parse (get_value (key), out res)) {
            return res;

        } else {
            resolve_key_file_error ();
            Process.exit (ExitCode.BASE_ERROR);
        }
    }

    public void set_boolean (string key, bool value) {
        set_value (key, value.to_string ());
    }

    public string get_string (string key) {
        return get_value (key);
    }

    public void set_string (string key, string value) {
        set_value (key, value);
    }
}
