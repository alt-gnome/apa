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

namespace Apa {
    const string SEARCH_FILE_PATTERN = "^[\\w/.+- $#%:=@{}]{3,}$";

    public async int search_file (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, ApiBase.CommonError, ApiBase.BadStatusCodeError, OptionsError {
        var all_possible_options = SearchFile.Data.COMMON_OPTIONS_DATA;
        var all_possible_arg_options = SearchFile.Data.COMMON_ARG_OPTIONS_DATA;

        args_handler.init_options (
            all_possible_options,
            all_possible_arg_options,
            skip_unknown_options
        );

        bool is_local = false;
        bool is_short = false;
        string branch = "sisyphus";
        string arch = get_arch ();

        foreach (var option in args_handler.options) {
            var option_data = OptionData.find_option (all_possible_options, option);

            switch (option_data.short_option) {
                case SearchFile.Data.OPTION_LOCAL_SHORT:
                    is_local = true;
                    break;

                case SearchFile.Data.OPTION_SHORT_SHORT:
                    is_short = true;
                    break;

                default:
                    assert_not_reached ();
            }
        }

        foreach (var arg_option in args_handler.arg_options) {
            var option_data = OptionData.find_option (all_possible_arg_options, arg_option.name);

            switch (option_data.short_option) {
                case SearchFile.Data.OPTION_BRANCH_SHORT:
                    branch = arg_option.value;
                    break;

                case SearchFile.Data.OPTION_ARCH_SHORT:
                    arch = arg_option.value;
                    break;

                default:
                    assert_not_reached ();
            }
        }

        if (args_handler.args.size == 0) {
            throw new CommandError.COMMON (_("Nothing to search"));
        }

        if (is_local) {
            foreach (var arg in args_handler.args) {
                if (!file_exists (arg)) {
                    throw new CommandError.COMMON (_("No such file or directory: `%s'").printf (arg));
                }
            }

            var search_error = new Gee.ArrayList<string> ();

            var status = yield Rpm.serch_file (
                new ArgsHandler.with_data (
                    {},
                    {},
                    args_handler.args.to_array ()
                ),
                null,
                search_error
            );

            if (search_error.size != 0) {
                string error_message = search_error[0].strip ();
                throw new CommandError.COMMON ("%c%s".printf (error_message[0].toupper (), error_message[1:error_message.length]));
            }

            return status;
        }

        var client = new AltRepo.Client ();

        var founded_files = new Gee.ArrayList<string> ();

        foreach (var arg in args_handler.args) {
            try {
                check_search_file_repo_arg (arg);
            } catch (SearchFileRepoPatternError e) {
                switch (e.code) {
                    case SearchFileRepoPatternError.NOT_AT_LEAST:
                        throw new CommandError.COMMON (_("The query must be at least %s symbols").printf (e.message));

                    case SearchFileRepoPatternError.WRONG_SYMBOL:
                        throw new CommandError.COMMON (_("The query cannot contain a `%s'").printf (e.message));

                    default:
                        assert_not_reached ();
                }
            }

            const int LIMIT = 5000;

            var result = yield client.get_file_search_async (branch, arg, LIMIT);
            founded_files.add_all_iterator (result.files.map<string> (file => { return file.file_name; }));
        }

        var search_files = new Gee.ArrayList<string> ();

        // ALT Repo API issue fix. It can't invalidate pathes with spaces
        // https://bugzilla.altlinux.org/show_bug.cgi?id=52411
        foreach (var founded_file in founded_files) {
            if (!founded_file.contains (" ")) {
                search_files.add (founded_file);
            }
        }

        if (search_files.size == 0) {
            throw new ApiBase.BadStatusCodeError.NOT_FOUND ("");
        }

        var result = yield client.post_package_packages_by_file_names_async (new AltRepo.PackagesByFileNamesJson () {
            branch = branch,
            arch = arch,
            files = search_files
        });

        var packages = result.packages;

        if (is_short) {
            foreach (var package in packages) {
                print ("%s: %s".printf (
                    package.name,
                    string.joinv (" ", package.files.to_array ())
                ));
            }

        } else {
            foreach (var package in packages) {
                print ("%s:".printf (package.name));

                foreach (var file in package.files) {
                    print ("  %s".printf (mark_text (file, args_handler.args.to_array ())));
                }
            }
        }

        return 0;
    }
}
