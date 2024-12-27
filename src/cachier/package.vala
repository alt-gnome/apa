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

public class Apa.Package : Object {

    public string package_id { get; set; }

    public string name { get; set; }

    public string summary { get; set; }

    public string version { get; set; }

    public string dist_tag { get; set; }

    public string arch { get; set; }

    public Package.from_pk (Pk.Package package) {
        //  var parts = package.get_version ().split ("@");

        //  if (parts.length > 0) {
        //      var parts2 = parts[0].split (":");
        //  }

        Object (
            package_id: package.package_id,
            name: package.get_name (),
            summary: package.summary,
            version: package.get_version (),
            arch: package.get_arch ()
        );
    }

    public Package.from_rpm (string rpm_name) {
        var result = simple_exec ({"rpm", "-qi", rpm_name}).split ("\n");

        string name = "";
        string summary = "";
        string version = "";
        string dist_tag = "";
        string arch = "";

        foreach (var line in result) {
            var parts = line.split (":", 1);
            var vname = parts[0].strip ();
            var value = parts[1].strip ();

            switch (vname) {
                case "Name":
                    name = value;
                    break;
                case "Version":
                    version = value;
                    break;
                case "Summary":
                    version = value;
                    break;
                case "DistTag":
                    dist_tag = value;
                    break;
                case "Architecture":
                    arch = value;
                    break;
            }
        }

        Object (
            package_id: "",
            name: name,
            summary: summary,
            version: version,
            arch: arch
        );
    }
}
