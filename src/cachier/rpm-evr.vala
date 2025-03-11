/*
 * Copyright (C) 2025 Vladimir Vaskov <rirusha@altlinux.org>
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
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Apa.RpmEVR {

    public uint? epoch { get; set; default = null; }

    public string? version { get; set; default = null; }

    public string? release { get; set; default = null; }

    public string evr_string {
        owned get {
            return "%s%s-%s".printf (
                epoch == null ? "" : "%u:".printf (epoch),
                version,
                release
            );
        }
    }

    public static RpmEVR from_evr_string (string evr) {
        var epoch_sep_loc = evr.index_of (":");
        var release_sep_loc = evr.index_of ("-");

        var rpm_evr = new RpmEVR ();

        if (epoch_sep_loc != -1) {
            if (evr[0:epoch_sep_loc] != "(none)") {
                rpm_evr.epoch = uint.parse (evr[0:epoch_sep_loc]);
            }
        }

        rpm_evr.version = evr[epoch_sep_loc + 1:release_sep_loc];
        rpm_evr.release = evr[release_sep_loc + 1:evr.length];

        return rpm_evr;
    }
}
