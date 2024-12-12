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

    const string REPO_LIST_SUBCOMMAND = "list";
    const string REPO_ADD_SUBCOMMAND = "add";
    const string ADD_AIDES_SUBCOMMAND = "add-aides";
    const string REPO_REMOVE_SUBCOMMAND = "remove";

    const string AIDES_REPO_URL = "";

    public async int repo (
        owned string[] argv,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        string? subcommand = cut_of_command (ref argv);

        var args_handler = new ArgsHandler (argv);

        switch (subcommand) {
            case REPO_LIST_SUBCOMMAND:
                return yield Repo.list (args_handler, skip_unknown_options);

            case REPO_ADD_SUBCOMMAND:
                check_is_root (subcommand);
                return yield Repo.add (args_handler, skip_unknown_options);

            case ADD_AIDES_SUBCOMMAND:
                print_error (_("Not implemented yet"));
                return ExitCode.BASE_ERROR;
                //  check_is_root (subcommand);
                //  return yield Repo.add (
                //      new ArgsHandler.with_data (
                //          args_handler.options.to_array (),
                //          args_handler.arg_options.to_array (),
                //          { AIDES_REPO_URL }
                //      ),
                //      skip_unknown_options
                //  );

            case REPO_REMOVE_SUBCOMMAND:
                check_is_root (subcommand);
                return yield Repo.remove (args_handler, skip_unknown_options);

            case null:
                Help.print_repo ();
                return ExitCode.BASE_ERROR;

            default:
                throw new CommandError.UNKNOWN_SUBCOMMAND (subcommand);
        }
    }
}
