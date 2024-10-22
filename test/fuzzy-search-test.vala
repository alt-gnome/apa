// ind-check=skip-file

public void fuzzy_search_test_base (
    string[] data,
    string query,
    Gee.ArrayList<Array<string?>>? expected_result
) {
    string?[]? result = Apa.fuzzy_search (query, data);
    string[]? expected = null;

    if (expected_result != null) {
        expected = new string[expected_result.size];
        for (int i = 0; i < expected.length; i++) {
            expected[i] = string.joinv (" | ", expected_result[i].data);
        }
    }

    print ("Fuck");

    string debug_info = "Query: %s\nData: { %s }\n\nResult: { %s }\nExpected: { %s }".printf (
        query,
        string.joinv (", ", data),
        result == null ? "null" : string.joinv (", ", result),
        expected == null ? "null" : string.joinv (", ", expected)
    );

    print ("Fuck2");

    if (result == null) {
        if (expected_result == null) {
            return;

        } else {
            Test.fail_printf (
                "\n\nExpected:\n\t%s\n\nGot:\n\t%s\n\n%s\n",
                string.joinv ("\n\t", expected),
                "`null`",
                debug_info
            );
        }

    } else {
        if (expected_result == null) {
            Test.fail_printf (
                "\n\nExpected:\n\t%s\n\nGot:\n\t%s\n\n%s\n",
                "'null`",
                string.joinv ("\n\t", result),
                debug_info
            );
        }
    }

    if (expected_result != null) {
        for (int i = 0; i < result.length; i++) {
            if (!(result[i] in expected_result[i].data)) {
                Test.fail_printf (
                    "\n\nExpected one of:\n\t%s\n\nGot:\n\t%s\nOn %i\n\n%s\n",
                    string.joinv ("\n\t", expected_result[i].data),
                    result[i],
                    i,
                    debug_info
                );
            }
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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({
            "python2-pytest",
            "python3-pytest"
        }));
        expected_result.add (new Array<string?>.take ({
            "python2-pytest",
            "python3-pytest"
        }));
        expected_result.add (new Array<string?>.take ({ "python3-pytest-cov" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "gcc" }));
        expected_result.add (new Array<string?>.take ({ "gcc-libs" }));
        expected_result.add (new Array<string?>.take ({ "gdb" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "perl-base" }));
        expected_result.add (new Array<string?>.take ({ "perl-utils" }));
        expected_result.add (new Array<string?>.take ({ null }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "vim" }));
        expected_result.add (new Array<string?>.take ({ "gvim" }));
        expected_result.add (new Array<string?>.take ({ "neovim" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "chromium" }));
        expected_result.add (new Array<string?>.take ({ null }));
        expected_result.add (new Array<string?>.take ({ null }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "openssl" }));
        expected_result.add (new Array<string?>.take ({ "openssl-dev" }));
        expected_result.add (new Array<string?>.take ({ "openssl-utils" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "libc" }));
        expected_result.add (new Array<string?>.take ({ "glibc" }));
        expected_result.add (new Array<string?>.take ({ "libcrypt" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "gzip" }));
        expected_result.add (new Array<string?>.take ({
            "bzip2",
            "unzip"
        }));
        expected_result.add (new Array<string?>.take ({
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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "python3" }));
        expected_result.add (new Array<string?>.take ({ "python2" }));
        expected_result.add (new Array<string?>.take ({ "python3-pip" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "bash" }));
        expected_result.add (new Array<string?>.take ({ "dash" }));
        expected_result.add (new Array<string?>.take ({ "sh" }));

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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "nginx" }));
        expected_result.add (new Array<string?>.take ({
            "nginx-full",
            "nginx-core",
            null
        }));
        expected_result.add (new Array<string?>.take ({
            "nginx-full",
            "nginx-core",
            null
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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({
            "python3-pytest",
            "python2-pytest"
        }));
        expected_result.add (new Array<string?>.take ({
            "python3-pytest",
            "python2-pytest"
        }));
        expected_result.add (new Array<string?>.take ({ null }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/13", () => {
        string[] data = {
            "perl-Test-Simple",
            "perl-Data-Dumper",
            "perl-utils",
            "python3-perl-parser",
            "perl"
        };

        string query = "prel";

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "perl" }));
        expected_result.add (new Array<string?>.take ({
            "perl-Test-Simple",
            "perl-Data-Dumper",
            null
        }));
        expected_result.add (new Array<string?>.take ({
            "perl-Test-Simple",
            "perl-Data-Dumper",
            null
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

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "fish" }));
        expected_result.add (new Array<string?>.take ({ null }));
        expected_result.add (new Array<string?>.take ({ null }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    Test.add_func ("/utils/fuzzy-search/15", () => {
        string[] data = {
            "openssl",
            "libssl",
            "gnutls",
            "openssl-utils"
        };

        string query = "opnssl";

        var expected_result = new Gee.ArrayList<Array<string?>> ();
        expected_result.add (new Array<string?>.take ({ "openssl" }));
        expected_result.add (new Array<string?>.take ({ "openssl-utils" }));
        expected_result.add (new Array<string?>.take ({ "libssl" }));

        fuzzy_search_test_base (data, query, expected_result);
    });

    return Test.run ();
}
