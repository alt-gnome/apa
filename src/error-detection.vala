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

namespace Apa {
    public enum OriginErrorType {
        COULDNT_FIND_PACKAGE,
        PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS,
        UNABLE_TO_LOCK_DOWNLOAD_DIR,
        NO_INSTALLATION_CANDIDAT,
        NONE,
    }

    public OriginErrorType detect_error (string error_message, out string package = null) {
        // Should be aligned with ErrorType enum
        string[] origin_errors = {
            "Couldn't find package %s",
            "Package %s is a virtual package with multiple good providers.\n",
            "Unable to lock the download directory",
            "Package %s has no installation candidate"
        };

        string pattern;
        Regex regex;
        package = null;

        try {
            for (int i = 0; i < origin_errors.length; i++) {
                pattern = dgettext (
                    "apt",
                    origin_errors[i]
                ).strip ().replace ("%s", "(.*)");

                regex = new Regex (
                    pattern,
                    RegexCompileFlags.OPTIMIZE,
                    RegexMatchFlags.NOTEMPTY
                );

                MatchInfo match_info;
                if (regex.match (error_message, 0, out match_info)) {
                    package = match_info.fetch (1);
                    return (OriginErrorType) i;

                } else {
                    print_devel ("\nError message: '%s'\nTranslated patern: '%s'\n".printf (origin_errors[i], pattern));
                }
            }

        } catch (Error e) {
            print_error (e.message);
        }

        return NONE;
    }

    public string normalize_error (Gee.ArrayList<string> error) {
        string error_message = "";

        for (int i = error.size - 1; i >= 0; i--) {
            if (error[i].strip () != "") {
                error_message = error[i].replace ("E: ", "").strip ();
                error.remove_at (i);
                break;

            } else {
                error.remove_at (i);
            }
        }

        for (int i = 0; i < error.size; i++) {
            if (error[i][error[i].length - 1] == '\n') {
                error[i] = error[i][0:error[i].length - 1];
            }
        }

        return error_message;
    }
}
