// ind-check=skip-file

public void fuzzy_search_test_base (
    string[] data,
    string query,
    List<Array<string?>>? expected_result
) {
    string?[]? result = Apa.fuzzy_search (query, data);

    if (result == null) {
        if (expected_result == null) {
            return;

        } else {
            Test.fail_printf (
                "\nExpected on of:\n%s\nGot:\n%s",
                string.joinv ("\n", expected_result.nth (0).data.data),
                "`null`"
            );
        }

    } else {
        if (expected_result == null) {
            Test.fail_printf (
                "\nExpected:\n%s\nGot:\n%s",
                "'null`",
                string.joinv ("\n", result)
            );
        }
    }

    for (int i = 0; i < result.length; i++) {
        if (!(result[i] in expected_result.nth (i).data.data)) {
            Test.fail_printf (
                "\nExpected on of:\n%s\nGot:\n%s\nOn %i",
                string.joinv ("\n", expected_result.nth (i).data.data),
                result[i],
                i
            );
        }
    }
}

public int main (string[] args) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    Test.init (ref args);

    Test.add_func ("/utils/fuzzy-search/1", () => {
        string[] data = {
            "python3-pytest",
            "python2-pytest",
            "python3-django",
            "perl-Test-Simple",
            "perl-Text-CSV",
            "ruby-nokogiri",
            "python3-requests",
            "python3-flask",
            "python3-pytest-cov",
            "python3-pylint",
        };

        string query = "pytest";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({
            "python2-pytest",
            "python3-pytest"
        }));
        expected_result.append (new Array<string?>.take ({
            "python2-pytest",
            "python3-pytest"
        }));
        expected_result.append (new Array<string?>.take ({ "python3-pytest-cov" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/2", () => {
        string[] data = {
            "gcc",
            "glibc",
            "gdb",
            "g++",
            "gcc-libs",
            "python3-gcc-binding"
        };

        string query = "gcc";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "gcc" }));
        expected_result.append (new Array<string?>.take ({ "gcc-libs" }));
        expected_result.append (new Array<string?>.take ({ "python3-gcc-binding" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/3", () => {
        string[] data = {
            "perl-base",
            "perl-Data-Dumper",
            "perl-Test-Simple",
            "python3-perl-parser",
            "perl-utils",
            "ruby-perl-bridge"
        };

        string query = "perl";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "perl-base" }));
        expected_result.append (new Array<string?>.take ({ "perl-utils" }));
        expected_result.append (new Array<string?>.take ({
            "perl-Data-Dumper",
            "perl-Test-Simple",
            "ruby-perl-bridge"
        }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/4", () => {
        string[] data = {
            "vim",
            "neovim",
            "gvim",
            "emacs",
            "nano",
            "vim-python3-support"
        };

        string query = "vim";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "vim" }));
        expected_result.append (new Array<string?>.take ({ "gvim" }));
        expected_result.append (new Array<string?>.take ({ "neovim" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/5", () => {
        string[] data = {
            "firefox",
            "chromium",
            "brave-browser",
            "midori",
            "konqueror",
            "chromium-browser"
        };

        string query = "chrome";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "chromium" }));
        expected_result.append (new Array<string?>.take ({ "chromium-browser" }));
        expected_result.append (new Array<string?>.take ({ null }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/6", () => {
        string[] data = {
            "openssl",
            "libssl",
            "gnutls",
            "libgnutls",
            "openssl-utils",
            "openssl-dev"
        };

        string query = "openssl";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "openssl" }));
        expected_result.append (new Array<string?>.take ({ "openssl-dev" }));
        expected_result.append (new Array<string?>.take ({ "openssl-utils" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/7", () => {
        string[] data = {
            "libc",
            "libcrypt",
            "libssl",
            "libpng",
            "libjpeg",
            "glibc"
        };

        string query = "libc";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "libc" }));
        expected_result.append (new Array<string?>.take ({ "glibc" }));
        expected_result.append (new Array<string?>.take ({ "libcrypt" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/8", () => {
        string[] data = {
            "zlib",
            "libzip",
            "bzip2",
            "gzip",
            "xz-utils",
            "unzip"
        };

        string query = "zip";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "gzip" }));
        expected_result.append (new Array<string?>.take ({
            "bzip2",
            "unzip"
        }));
        expected_result.append (new Array<string?>.take ({
            "bzip2",
            "unzip"
        }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/9", () => {
        string[] data = {
            "python3",
            "python2",
            "python3-pip",
            "python2-pip",
            "python3-virtualenv",
            "python-pip"
        };

        string query = "python3";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "python3" }));
        expected_result.append (new Array<string?>.take ({ "python2" }));
        expected_result.append (new Array<string?>.take ({ "python3-pip" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/10", () => {
        string[] data = {
            "bash",
            "zsh",
            "dash",
            "fish",
            "csh",
            "sh"
        };

        string query = "bash";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "bash" }));
        expected_result.append (new Array<string?>.take ({ "dash" }));
        expected_result.append (new Array<string?>.take ({ null }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/11", () => {
        string[] data = {
            "nginx",
            "apache2",
            "lighttpd",
            "nginx-full",
            "nginx-core",
            "apache2-utils"
        };

        string query = "ngunx";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "nginx" }));
        expected_result.append (new Array<string?>.take ({
            "nginx-full",
            "nginx-core"
        }));
        expected_result.append (new Array<string?>.take ({
            "nginx-full",
            "nginx-core"
        }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/12", () => {
        string[] data = {
            "python3-pytest",
            "python3-numpy",
            "python3-scipy",
            "python3-matplotlib",
            "python2-pytest"
        };

        string query = "pytestt";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({
            "python3-pytest",
            "python2-pytest"
        }));
        expected_result.append (new Array<string?>.take ({
            "python3-pytest",
            "python2-pytest"
        }));
        expected_result.append (new Array<string?>.take ({ null }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/13", () => {
        string[] data = {
            "perl-Test-Simple",
            "perl-Data-Dumper",
            "perl-utils",
            "python3-perl-parser"
        };

        string query = "prel";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "perl-utils" }));
        expected_result.append (new Array<string?>.take ({
            "perl-Test-Simple",
            "perl-Data-Dumper"
        }));
        expected_result.append (new Array<string?>.take ({
            "perl-Test-Simple",
            "perl-Data-Dumper"
        }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/14", () => {
        string[] data = {
            "bash",
            "zsh",
            "dash",
            "fish"
        };

        string query = "foo";

        fuzzy_search_test_base (data, query, null);
    });

    Test.add_func ("/utils/fuzzy-search/15", () => {
        string[] data = {
            "openssl",
            "libssl",
            "gnutls",
            "openssl-utils"
        };

        string query = "opnssl";

        var expected_result = new List<Array<string?>> ();
        expected_result.append (new Array<string?>.take ({ "openssl" }));
        expected_result.append (new Array<string?>.take ({ "openssl-utils" }));
        expected_result.append (new Array<string?>.take ({ null }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    return Test.run ();
}
