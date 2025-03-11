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

public enum Apa.PackageStatus {
    INSTALLED,
    NOT_INSTALLED,
    CAN_BE_UPGRADED;

    public string to_string () {
        switch (this) {
            case INSTALLED:
                return _("Installed");
            case NOT_INSTALLED:
                return _("Not installed");
            case CAN_BE_UPGRADED:
                return _("Can be upgraded");
            default:
                assert_not_reached ();
        }
    }
}

public class Apa.Package : Object {

    public string name { get; set; }

    public string category { get; set; }

    public RpmEVR evr { get; set; }

    public Gee.ArrayList<string> pre_depends { get; set; default = new Gee.ArrayList<string> (); }

    public Gee.ArrayList<string> depends { get; set; default = new Gee.ArrayList<string> (); }

    public Gee.ArrayList<string> provides { get; set; default = new Gee.ArrayList<string> (); }

    public string arch { get; set; }

    public string summary { get; set; }

    public string description { get; set; }

    //  public int64 installed_size { get; set; }

    //  public int64 size { get; set; }

    public PackageStatus status { get; set; default = PackageStatus.NOT_INSTALLED; }
}
