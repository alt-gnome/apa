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

namespace Apa.Progress {
    public static string efill (string str, int width) {
        if (str.length >= width) {
            return str;
        } else {
            int padding = width - str.length;
            return string.nfill (padding, ' ') + str;
        }
    }

    void print_progress_line (int done, int undone, bool with_return = false) {
        print ("[%s%s]".printf (
            string.nfill (done, '='),
            string.nfill (undone, '-')
        ), with_return);
    }

    void remove_progress_line (bool with_return = false) {
        print (string.nfill (maximum_size + (with_return ? 3 : 2), '\b'), false);
    }

    bool size_locked = false;
    int maximum_size = 20;

    void print_progress (int progress) {
        if (!size_locked) {
            var columns = Environment.get_variable ("COLUMNS");
            if (columns == null) {
                columns = "20";
            }

            int int_columns;
            if (int.try_parse (columns, out int_columns)) {
                maximum_size = int_columns;
            } else {
                maximum_size = 20;
            }
        }

        int done = maximum_size * (progress / 100);
        int undone = maximum_size - done;

        if (progress == -1) {
            size_locked = true;
            print ("");

        } else if (progress == 100) {
            remove_progress_line ();
            print_progress_line (done, undone, true);
            size_locked = false;

        } else if (progress == 0) {
            if (last_progress == 100) {
                remove_progress_line (true);
            }
            print_progress_line (done, undone);

        } else {
            remove_progress_line ();
            print_progress_line (done, undone);
        }

        last_progress = progress;
    }

    int last_progress = -1;

    void progress_callback (Pk.Progress progress, Pk.ProgressType type) {
        switch (type) {
            case PACKAGE_ID:
                //  print_devel ("Working with %s".printf (progress.package_id.to_string ()));
                break;
            case TRANSACTION_ID:
                //  print_devel ("Transaction ID: %s".printf (progress.transaction_id.to_string ()));
                break;
            case PERCENTAGE:
                print_progress (progress.percentage);
                break;
            case ALLOW_CANCEL:
                //  print_devel ("Cancel %s".printf (progress.allow_cancel ? "allowed" : "not allowed"));
                break;
            case STATUS:
                print (@"$(progress.get_status ().to_localised_text ())…");
                break;
            case ROLE:
                print ("Role: %s".printf (progress.get_role ().to_localised_present ()));
                break;
            case CALLER_ACTIVE:
                //  print_devel ("Caller %s".printf (progress.caller_active ? "connected" : "disconnected"));
                break;
            case ELAPSED_TIME:
                print ("Elapsed time: %l".printf (progress.elapsed_time));
                break;
            case REMAINING_TIME:
                print ("Remaining time: %l".printf (progress.remaining_time));
                break;
            case SPEED:
                print ("Speed: %l".printf (progress.speed));
                break;
            case DOWNLOAD_SIZE_REMAINING:
                print ("Download size remaining: %s".printf (progress.download_size_remaining.to_string ()));
                break;
            case UID:
                //  print_devel ("Uid: %l".printf (progress.uid));
                break;
            case PACKAGE:
                print ("Package name: %s".printf (progress.package.get_name ()));
                break;
            case ITEM_PROGRESS:
                message ("ITEM PROGRESS");
                break;
            case TRANSACTION_FLAGS:
                //  print_devel ("Transaction flags: %s".printf (progress.get_transaction_flags ().to_string ()));
                break;
            case INVALID:
                print_devel ("INVALID");
                break;
        }
    }
}
