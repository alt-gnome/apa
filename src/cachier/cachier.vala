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

    async PackageList get_packages_list () {
        try {
            var pk_client = new Pk.Client ();
            var results = yield pk_client.get_packages_async (Pk.Filter.NONE, null, () => {});
            var all_packages = results.get_package_array ();

            var package_list = new PackageList ();
            foreach (var package in all_packages) {
                package_list.packages.add (new Package.from_pk (package));
            }

            return package_list;
        } catch (Error e) {
            print_error (e.message);
            Process.exit (ExitCode.BASE_ERROR);
        }
    }

    public async Package[] get_all_packages () {
        File cache_file = File.new_build_filename (cache_dir_file.peek_path (), "packages.cache");

        // Temporary disabled, becaoues of bad working
        //  if (!cache_file.query_exists ()) {
        if (true) {
            return yield update_packages_cache ();
        }

        try {
            string json_data;
            FileUtils.get_contents (cache_file.peek_path (), out json_data);

            var jsoner = new ApiBase.Jsoner (json_data, null, ApiBase.Case.KEBAB);
            var package_list = (PackageList) yield jsoner.deserialize_object_async (typeof (PackageList));

            return package_list.packages.to_array ();
        } catch (Error e) {
            return (yield get_packages_list ()).packages.to_array ();
        }
    }

    public async Package[] get_installed_packages () {
        var package_list = new PackageList ();
        Package last_package = new Package ();
        foreach (var line in yield Rpm.info (yield Rpm.list ())) {
            var parts = line.split (":", 12);
            var vname = parts[0].strip ();
            var value = parts.length > 1 ? parts[1].strip () : "";

            switch (vname) {
                case "Name":
                    last_package = new Package ();
                    package_list.packages.add (last_package);

                    last_package.name = value;
                    break;
                case "Version":
                    last_package.version = value;
                    break;
                case "Summary":
                    last_package.summary = value;
                    break;
                case "DistTag":
                    last_package.dist_tag = value;
                    break;
                case "Architecture":
                    last_package.arch = value;
                    break;
            }
        }

        package_list.packages.sort ((a, b) => {
            return strcmp (a.name, b.name);
        });

        return package_list.packages.to_array ();
    }

    public async Package[] update_packages_cache () {
        File cache_file = File.new_build_filename (cache_dir_file.peek_path (), "packages.cache");

        var package_list = yield get_packages_list ();

        string json_data = yield ApiBase.Jsoner.serialize_async (package_list, ApiBase.Case.KEBAB);

        try {
            FileUtils.set_contents (cache_file.peek_path (), json_data);
        } catch (Error e) {
            print_error (e.message);
        }

        return package_list.packages.to_array ();
    }
}
