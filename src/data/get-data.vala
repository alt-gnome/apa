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

namespace Apa.AptGet.Data {

    OptionEntity?[] common_options () {
        return {
            {
                "-h", "--hide-progress",
                "-q",
                Descriptions.option_hide_progress ()
            },
            {
                "-q", "--quiet",
                "-qq",
                Descriptions.option_quiet ()
            },
            {
                "-s", "--simulate",
                "-s",
                Descriptions.option_simulate ()
            },
            {
                "-y", "--yes",
                "-y",
                Descriptions.option_yes ()
            },
            {
                "-f", "--fix",
                "-f",
                Descriptions.option_fix ()
            },
            {
                "-V", "--version-detailed",
                "-V",
                Descriptions.option_version_detailed ()
            },
            {
                "-n", "--no-download",
                "--no-download",
                Descriptions.option_no_download ()
            },
            {
                "-i", "--ignore-missing",
                "--ignore-missing",
                Descriptions.option_ignore_missing ()
            }
        };
    }

    OptionEntity?[] common_arg_options () {
        return {
            {
                "-o", "--option",
                "-o",
                Descriptions.arg_option_option ()
            },
            {
                "-c", "--config-file",
                "-c",
                Descriptions.arg_option_config_file ()
            },
        };
    }

    public OptionEntity?[] update_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] update_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public const string OPTION_WITH_KERNEL_SHORT = "-k";
    public const string OPTION_WITH_KERNEL_LONG = "--with-kernel";

    public OptionEntity?[] upgrade_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-d", "--download-only",
                    "-d",
                    Descriptions.option_download_only ()
                },
                {
                    "-u", "--upgraded-show",
                    "-u",
                    Descriptions.option_upgraded_show ()
                },
                {
                    OPTION_WITH_KERNEL_SHORT, OPTION_WITH_KERNEL_LONG,
                    null,
                    Descriptions.option_with_kernel ()
                },
            }
        );
    }

    public OptionEntity?[] upgrade_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] do_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-d", "--download-only",
                    "-d",
                    Descriptions.option_download_only ()
                },
                {
                    "-D", "--with-dependecies",
                    "-D",
                    Descriptions.option_with_dependencies ()
                },
                {
                    "-r", "--reinstall",
                    "--reinstall",
                    Descriptions.option_reinstall ()
                }
            }
        );
    }

    public OptionEntity?[] do_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] install_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-d", "--download-only",
                    "-d",
                    Descriptions.option_download_only ()
                },
                {
                    "-r", "--reinstall",
                    "--reinstall",
                    Descriptions.option_reinstall ()
                }
            }
        );
    }

    public OptionEntity?[] install_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] remove_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-D", "--with-dependecies",
                    "-D",
                    Descriptions.option_with_dependencies ()
                }
            }
        );
    }

    public OptionEntity?[] remove_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] source_options () {
        return OptionEntity.concat (
            common_options (),
            {
                {
                    "-b", "--build",
                    "-b",
                    Descriptions.option_build ()
                }
            }
        );
    }

    public OptionEntity?[] source_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }

    public OptionEntity?[] autoremove_options () {
        return OptionEntity.concat (
            common_options (),
            {}
        );
    }

    public OptionEntity?[] autoremove_arg_options () {
        return OptionEntity.concat (
            common_arg_options (),
            {}
        );
    }
}
