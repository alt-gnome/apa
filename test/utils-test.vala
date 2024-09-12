public int main (string[] args) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    Test.init (ref args);

    Test.add_func ("/utils/fuzzy-search/1", () => {
        string[] data = {
            "gnome-clocks",
            "codeblock",
            "clacks",
        };

        string query = "clocks";

        string?[]? result = Apa.fuzzy_search (query, data);

        string?[]? expected_result = {
            "gnome-clocks",
            "clacks",
            null
        };

        if (result == null) {
            Test.fail_printf ("`result` is `null` while shouldn't");
        }

        for (int i = 0; i < result.length; i++) {
            if (result[i] != expected_result[i]) {
                Test.fail_printf ("Element %i is `%s`, expected: `%s`", i, result[i], expected_result[i]);
            }
        }
    });

    return Test.run ();
}
