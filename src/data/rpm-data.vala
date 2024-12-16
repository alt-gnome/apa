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

namespace Apa.Rpm.Data {

    OptionEntity?[] common_options () {
        return {};
    }

    OptionEntity?[] common_arg_options () {
        return {};
    }

    public const string OPTION_SORT_SHORT = "-s";
    public const string OPTION_SORT_LONG = "--sort";
    public const string OPTION_ASORT_SHORT = "-as";
    public const string OPTION_ASORT_LONG = "--asort";
    public const string OPTION_WITH_DATE_SHORT = "-d";
    public const string OPTION_WITH_DATE_LONG = "--with-date";
    public const string OPTION_RPM_SHORT = "-r";
    public const string OPTION_RPM_LONG = "--rpm";

    public OptionEntity?[] list_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    OPTION_SORT_SHORT, OPTION_SORT_LONG,
                    null,
                    Descriptions.option_sort ()
                },
                {
                    OPTION_ASORT_SHORT, OPTION_ASORT_LONG,
                    null,
                    Descriptions.option_asort ()
                },
                {
                    OPTION_WITH_DATE_SHORT, OPTION_WITH_DATE_LONG,
                    "--last",
                    Descriptions.option_with_date ()
                },
                {
                    OPTION_RPM_SHORT, OPTION_RPM_LONG,
                    null,
                    Descriptions.option_rpm ()
                },
            }
        );
    }

    public const string OPTION_QUERYFORMAT_SHORT = "-qf";
    public const string OPTION_QUERYFORMAT_LONG = "--queryformat";

    public OptionEntity?[] list_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {
                {
                    OPTION_QUERYFORMAT_SHORT, OPTION_QUERYFORMAT_LONG,
                    "--queryformat",
                    Descriptions.arg_option_queryformat ()
                },
            }
        );
    }

    public OptionEntity?[] info_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-f", "--files",
                    "-l",
                    Descriptions.option_files ()
                }
            }
        );
    }

    public OptionEntity?[] info_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] search_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] search_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }
}
