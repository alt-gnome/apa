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

    public OptionEntity?[] list_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-s", "--short",
                    "--queryformat=%{NAME}\n",
                    Descriptions.option_short ()
                }
            }
        );
    }

    public OptionEntity?[] list_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
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
