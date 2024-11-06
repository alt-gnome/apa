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

    // Should be aligned with ErrorType enum
    const string[] ORIGIN_ERRORS = {
        "Couldn't find package %s",
        "Package %s is a virtual package with multiple good providers.\n",
        "Unable to lock the download directory",
        "Package %s has no installation candidate",
        "Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?",
        "Some index files failed to download. They have been ignored, or old ones used instead.",
    };

    public enum OriginErrorType {
        COULDNT_FIND_PACKAGE,
        PACKAGE_VIRTUAL_WITH_MULTIPLE_GOOD_PROIDERS,
        UNABLE_TO_LOCK_DOWNLOAD_DIR,
        NO_INSTALLATION_CANDIDAT,
        UNABLE_TO_FETCH_SOME_ARCHIVES,
        SOME_INDEX_FILES_FAILED_TO_DOWNLOAD,
        NONE,
    }

    public OriginErrorType detect_error (string error_message, out string package = null) {
        string pattern;
        Regex regex;
        package = null;

        try {
            for (int i = 0; i < ORIGIN_ERRORS.length; i++) {
                pattern = dgettext (
                    "apt",
                    ORIGIN_ERRORS[i]
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
                    print_devel ("\nError message: '%s'\nTranslated patern: '%s'\n".printf (ORIGIN_ERRORS[i], pattern));
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
