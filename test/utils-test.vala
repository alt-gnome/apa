// ind-check=skip-file

public void test_array (string[] input, string[] expected_result, int index) {
    string[] result = input.copy ();
    Apa.remove_element_from_array_by_index (ref result, index);

    bool all_good = true;

    if (result.length == expected_result.length) {
        for (int i = 0; i < result.length; i++) {
            if (result[i] != expected_result[i]) {
                all_good = false;
                break;

            }
        }

    } else {
        all_good = false;
    }

    if (all_good) {
        return;

    } else {
        Test.fail_printf (
            "\nInput: { %s }\nResult: { %s }\nExpected: { %s }",
            string.joinv (", ", input),
            string.joinv (", ", result),
            string.joinv (", ", expected_result)
        );
    }
}

public int main (string[] args) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    Test.init (ref args);

    Test.add_func ("/utils/remove-element/1", () => {
        test_array ({ "1", "2", "3" }, { "1", "3" }, 1);
    });

    Test.add_func ("/utils/remove-element/2", () => {
        test_array ({ "1", "2", "3" }, { "2", "3" }, 0);
    });

    Test.add_func ("/utils/remove-element/3", () => {
        test_array ({ "1", "2", "3" }, { "1", "2" }, 2);
    });

    return Test.run ();
}
