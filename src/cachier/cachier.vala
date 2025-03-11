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

public sealed class Apa.Cachier : Object {

    static Cachier instance;

    File cache_dir_file = File.new_build_filename (Environment.get_user_cache_dir (), "apa", "cache");

    construct {
        if (!cache_dir_file.query_exists ()) {
            try {
                cache_dir_file.make_directory_with_parents ();

            } catch (Error e) {
                print_error (e.message);
                Process.exit (ExitCode.BASE_ERROR);
            }
        }
    }

    public static Cachier get_default () {
        if (instance == null) {
            instance = new Cachier ();
        }

        return instance;
    }

    async PackagesList get_packages_list (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) {
        try {
            var result = new Gee.ArrayList<string> ();
            yield AptCache.dumpavail (args_handler, result, error, skip_unknown_options);

            var packages_list = new PackagesList ();
            Package current_package = null;
            string version;

            bool desc_now = false;
            var desc = new Gee.ArrayList<string> ();

            foreach (var str in result) {
                if (str.length < 9 && !(str.has_prefix (" ") && desc_now)) {
                    continue;
                }

                if (str.has_prefix (" ") && desc_now) {
                    desc.add (str.strip ());

                    continue;
                }

                switch (str[0:9]) {
                    case "Package: ":
                        current_package = new Package ();
                        current_package.name = do_string ("Package: ", str);

                        packages_list.packages.set (current_package.name, current_package);
                        break;

                    case "Section: ":
                        current_package.category = do_string ("Section: ", str);
                        break;

                    case "Version: ":
                        version = do_string ("Version: ", str).split ("@")[0].split (":sisyphus")[0];
                        current_package.evr = RpmEVR.from_evr_string (version != null ? version : "0-alt1");
                        break;

                    //  case "Pre-Depen":
                    //      current_package.pre_depends.add_all_iterator (do_list ("Pre-Depends: ", str));
                    //      break;

                    //  case "Depends: ":
                    //      current_package.depends.add_all_iterator (do_list ("Depends: ", str));
                    //      break;

                    //  case "Provides:":
                    //      current_package.provides.add_all_iterator (do_list ("Provides: ", str));
                    //      break;

                    case "Architect":
                        current_package.arch = do_string ("Architecture: ", str);
                        break;

                    case "Descripti":
                        desc_now = true;
                        current_package.summary = do_string ("Description: ", str);
                        continue;
                }

                if (desc_now) {
                    desc_now = false;
                    current_package.description = string.joinv (" ", desc.to_array ());
                    desc.clear ();
                }
            }

            result.clear ();

            //  FIXME: Make Rpm.list more friendly to use without args_handler.init_options
            var rpm_result = simple_exec ({"rpm", "-qa", "--queryformat=%{NAME}|%{EPOCH}:%{VERSION}-%{RELEASE}|%{ARCH}\n"});
            string[] pkg_info;
            string pkg_name;
            RpmEVR pkg_evr;
            string pkg_arch;

            foreach (var str in rpm_result.split ("\n")) {
                pkg_info = str.split ("|");
                pkg_name = pkg_info[0];

                //  if (pkg_info[1] == null) {
                //      GLib.error (str);
                //  }

                pkg_evr = RpmEVR.from_evr_string (pkg_info[1]);
                pkg_arch = pkg_info[2];

                if (packages_list.packages.has_key (pkg_name)) {
                    if (packages_list.packages[pkg_name].arch == pkg_arch) {
                        switch (rpm_evr_compare (pkg_evr, packages_list.packages[pkg_name].evr)) {
                            case -1:
                                packages_list.packages[pkg_name].status = PackageStatus.CAN_BE_UPGRADED;
                                break;
                            case 0:
                                packages_list.packages[pkg_name].status = PackageStatus.INSTALLED;
                                break;
                            case 1:
                                packages_list.packages[pkg_name].status = PackageStatus.INSTALLED;
                                break;
                        }
                    }
                }
            }

            return packages_list;

        } catch (Error e) {
            print_error (e.message);
            Process.exit (ExitCode.BASE_ERROR);
        }
    }

    public async Package[] get_all_packages (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) {
        File cache_file = File.new_build_filename (cache_dir_file.peek_path (), "packages.cache");

        // Temporary disabled, because of bad working
        //  if (!cache_file.query_exists ()) {
        if (true) {
            return yield update_packages_cache (args_handler, error, skip_unknown_options);
        }

        try {
            string json_data;
            FileUtils.get_contents (cache_file.peek_path (), out json_data);

            var jsoner = new ApiBase.Jsoner (json_data, null, ApiBase.Case.KEBAB);
            var package_list = (PackagesList) yield jsoner.deserialize_object_async (typeof (PackagesList));

            return package_list.get_array ();
        } catch (Error e) {
            return (yield get_packages_list (args_handler)).get_array ();
        }
    }

    public async Package[] get_installed_packages (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) {
        var packages = yield get_all_packages (args_handler, error, skip_unknown_options);

        var installed_package = new Gee.ArrayList<Package> ();
        foreach (var package in packages) {
            if (package.status == PackageStatus.INSTALLED) {
                installed_package.add (package);
            }
        }

        return installed_package.to_array ();
    }

    public async Package[] get_upgradable_packages (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) {
        var packages = yield get_all_packages (args_handler, error, skip_unknown_options);

        var installed_package = new Gee.ArrayList<Package> ();
        foreach (var package in packages) {
            if (package.status == PackageStatus.CAN_BE_UPGRADED) {
                installed_package.add (package);
            }
        }

        return installed_package.to_array ();
    }

    public async Package[] update_packages_cache (
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) {
        File cache_file = File.new_build_filename (cache_dir_file.peek_path (), "packages.cache");

        var package_list = yield get_packages_list (args_handler, error, skip_unknown_options);

        //  string json_data = yield ApiBase.Jsoner.serialize_async (package_list, ApiBase.Case.KEBAB);

        //  try {
        //      FileUtils.set_contents (cache_file.peek_path (), json_data);
        //  } catch (Error e) {
        //      print_error (e.message);
        //  }

        return package_list.get_array ();
    }

    string do_string (string name, string str) {
        return str.replace (name, "").strip ();
    }

    Gee.Iterator<string> do_list (string name, string str) {
        var packages = new Gee.ArrayList<string>.wrap (str.replace (name, "").split (", "));
        return packages.map<string> ((el) => {
            return el.split (" ")[0].strip ();
        });
    }

    /**
     * Segmented string compare for version or release strings.
     *
     * @param a             1st string
     * @param b             2nd string
     * @return              +1 if a is "newer", 0 if equal, -1 if b is "newer"
     */
    int rpm_evr_compare (RpmEVR fst, RpmEVR snd) {
        int rc = cmp_uint (fst.epoch != null ? fst.epoch : 0, snd.epoch != null ? snd.epoch : 0);
        if (rc != 0)
            return rc;

        if (fst.version == null && snd.version != null)
            return -1;
        if (fst.version != null && snd.version == null)
            return 1;
        if (fst.version != null && snd.version != null)
            rc = rpmvercmp (fst.version, snd.version);
        if (rc != 0) return rc;

        if (fst.release == null && snd.release != null)
            return -1;
        if (fst.release != null && snd.release == null)
            return 1;
        if (fst.release != null && snd.release != null)
            rc = rpmvercmp (fst.release, snd.release);

        return rc;
    }

    int cmp_uint (ulong one, ulong two) {
        if (one < two)
            return -1;
        if (one > two)
            return 1;
        return 0;
    }

    public async Package[] simple_search (
        string pattern,
        bool names_only = false,
        owned ArgsHandler args_handler,
        Gee.ArrayList<string>? error = null,
        bool skip_unknown_options = false
    ) {
        try {
            var regex = new Regex (
                pattern,
                RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS,
                RegexMatchFlags.NOTEMPTY
            );

            var result = new Gee.ArrayList<Package> ();
            MatchInfo match_info;

            foreach (var package in yield get_all_packages (args_handler, error, skip_unknown_options)) {
                if (regex.match (package.name, 0) && names_only ? true : regex.match (package.summary, 0)) {
                    result.add (package);
                }
            }

            return result.to_array ();
        } catch (Error e) {
            warning (e.message);
        }

        return {};
    }
}
