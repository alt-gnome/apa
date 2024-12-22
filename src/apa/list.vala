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

    struct RpmDate {
        public DateTime install_date;
        public string other;
    }

    public async int list (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        var result = new Gee.ArrayList<string> ();
        var error = new Gee.ArrayList<string> ();

        bool sort = false;
        int sort_mod = 1;
        bool with_date = false;
        bool rpm = false;
        string? query_format = null;

        foreach (var option in args_handler.options) {
            var option_data = OptionEntity.find_option (Rpm.Data.list_options (), option);

            switch (option_data.short_option) {
                case Rpm.Data.OPTION_SORT_SHORT:
                    sort = true;
                    break;

                case Rpm.Data.OPTION_ASORT_SHORT:
                    sort = true;
                    sort_mod = -1;
                    break;

                case Rpm.Data.OPTION_RPM_SHORT:
                    rpm = true;
                    break;

                case Rpm.Data.OPTION_WITH_DATE_SHORT:
                    with_date = true;
                    break;
            }
        }

        foreach (var option in args_handler.arg_options) {
            var option_data = OptionEntity.find_option (Rpm.Data.list_arg_options (), option.name);

            switch (option_data.short_option) {
                case Rpm.Data.OPTION_QUERYFORMAT_SHORT:
                    query_format = option.value;
                    break;
            }
        }

        if (rpm) {
            args_handler.remove_option (Rpm.Data.OPTION_RPM_SHORT);
            args_handler.remove_option (Rpm.Data.OPTION_RPM_LONG);

            if (query_format != null) {
                args_handler.remove_option (Rpm.Data.OPTION_QUERYFORMAT_LONG);
                args_handler.remove_option (Rpm.Data.OPTION_QUERYFORMAT_SHORT);
            }

        } else {
            if (query_format != null) {
                if (with_date) {
                    args_handler.remove_option (Rpm.Data.OPTION_WITH_DATE_SHORT);
                    args_handler.remove_option (Rpm.Data.OPTION_WITH_DATE_LONG);
                }

            } else {
                if (with_date) {
                    args_handler.remove_option (Rpm.Data.OPTION_WITH_DATE_SHORT);
                    args_handler.remove_option (Rpm.Data.OPTION_WITH_DATE_LONG);

                    args_handler.arg_options.add ({ name: Rpm.Data.OPTION_QUERYFORMAT_LONG, value: "%{INSTALLTIME}::::%{INSTALLTIME:date} : %{NAME} - %{SUMMARY}\n" });
                } else {
                    args_handler.arg_options.add ({ name: Rpm.Data.OPTION_QUERYFORMAT_LONG, value: "%{NAME} - %{SUMMARY}\n" });
                }
            }
        }

        foreach (var option in args_handler.arg_options) {
            var option_data = OptionEntity.find_option (Rpm.Data.list_arg_options (), option.name);

            switch (option_data.short_option) {
                case Rpm.Data.OPTION_QUERYFORMAT_SHORT:
                    if (option.value != null) {
                        if (!option.value.has_suffix ("\n")) {
                            option.value += "\n";
                        }
                    }
                    break;
            }
        }

        while (true) {
            result.clear ();
            error.clear ();

            //  var status = yield Rpm.list (args_handler, result, error, skip_unknown_options);

            //  if (status != ExitCode.SUCCESS && error.size > 0) {
            //      string error_message = normalize_error (error);
            //      string[] error_sources;

            //      switch (detect_error (error_message, out error_sources)) {
            //          case OriginErrorType.NONE:
            //          default:
            //              throw new CommandError.UNKNOWN_ERROR (error_message);
            //      }

            //  } else {
            //      if (sort) {
            //          if (!rpm && query_format == null && with_date) {
            //              var result_with_date = new Gee.ArrayList<RpmDate?> ();

            //              foreach (var line in result) {
            //                  var parts = line.split ("::::");

            //                  result_with_date.add ({
            //                      install_date: new DateTime.from_unix_local (int64.parse (parts[0])),
            //                      other: parts[1]
            //                  });
            //              }
            //              result.clear ();

            //              result_with_date.sort ((a, b) => b.install_date.compare (a.install_date) * sort_mod);
            //              result.add_all_iterator (result_with_date.map<string> (x => x.other));

            //          } else {
            //              result.sort ((a, b) => {
            //                  return strcmp (a, b) * sort_mod;
            //              });
            //          }
            //      }

            //      foreach (var line in result) {
            //          print (line);
            //      }

            //      return status;
            //  }

            return 100;
        }
    }
}
