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

namespace Apa.Constants {

    namespace ExitCode {
        public const int SUCCESS = 0;
        public const int BASE_ERROR = 100;
    }

    namespace Colors {
        public const string HEADER = "\033[95m";
        public const string OKBLUE = "\033[94m";
        public const string CYAN = "\033[96m";
        public const string OKGREEN = "\033[92m";
        public const string YELLOW = "\033[93m";
        public const string FAIL = "\033[91m";
        public const string ENDC = "\033[0m";
        public const string BOLD = "\033[1m";
        public const string UNDERLINE = "\033[4m";
    }
}
