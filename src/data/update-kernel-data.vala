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

 namespace Apa.UpdateKernel.Data {

    OptionEntity?[] common_options () {
        return {};
    }

    OptionEntity?[] common_arg_options () {
        return {};
    }

    public OptionEntity?[] update_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-y", "--yes",
                    "-f",
                    Descriptions.option_force ()
                },
                {
                    "-d", "--download-only",
                    "-d",
                    Descriptions.option_download_only ()
                },
                {
                    "-s", "--simulate",
                    "-n",
                    Descriptions.option_simulate ()
                },
                {
                    "-H", "--header",
                    "-H",
                    Descriptions.option_header ()
                },
                {
                    "-a", "--all",
                    "-a",
                    Descriptions.option_all ()
                },
                {
                    "-i", "--interactive",
                    "-i",
                    Descriptions.option_interactive ()
                },
                {
                    "-d", "--debuginfo",
                    "--debuginfo",
                    Descriptions.option_debuginfo ()
                }
            }
        );
    }

    public OptionEntity?[] update_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {
                {
                    "-A", "--add-module",
                    "-A",
                    Descriptions.arg_option_add_module ()
                },
                {
                    "-D", "--del-module",
                    "-D",
                    Descriptions.arg_option_del_module ()
                },
                {
                    "-t", "--type",
                    "-t",
                    Descriptions.arg_option_type ()
                },
                {
                    "-r", "--release",
                    "-r",
                    Descriptions.arg_option_release ()
                }
            }
        );
    }

    public OptionEntity?[] list_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] list_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }
}
