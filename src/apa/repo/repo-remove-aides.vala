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

namespace Apa.Repo {

    public async int remove_aides (
        owned ArgsHandler args_handler,
        bool skip_unknown_options = false
    ) throws CommandError, OptionsError {
        int status = ExitCode.SUCCESS;

        status = yield Repo.remove (
            new ArgsHandler.with_data (
                args_handler.options.to_array (),
                args_handler.arg_options.to_array (),
                { get_aides_repo_source (false) }
            ),
            skip_unknown_options
        );

        if (status != ExitCode.SUCCESS) {
            return status;
        }

        status = yield Repo.remove (
            new ArgsHandler.with_data (
                args_handler.options.to_array (),
                args_handler.arg_options.to_array (),
                { get_aides_repo_source (true) }
            ),
            skip_unknown_options
        );

        return status;
    }
}
