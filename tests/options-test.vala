// ind-check=skip-file

void check_command_entity (string? source, Apa.CommandEntity command_entity) {
    var all_options = new Gee.HashSet<string> ();

    foreach (var option in Apa.OptionEntity.concat (command_entity.options.to_array (), command_entity.arg_options.to_array ())) {
        for (int i = 0; i < 2; i++) {
            string cur_option = i == 0 ? option.short_option : option.long_option;
            if (cur_option in all_options) {
                Test.fail_printf (
                    "Option duplicate: `%s' in `%s' commands",
                    cur_option,
                    "%s %s".printf (
                        source ?? "",
                        command_entity.name
                    )
                );
            }
            all_options.add (cur_option);
        }
    }
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/options", () => {
        foreach (var command_entity in Apa.Commands.Data.all_commands ()) {
            if (command_entity.subcommands == null) {
                check_command_entity (null, command_entity);
            } else {
                foreach (var subcommand_entity in command_entity.subcommands) {
                    check_command_entity (command_entity.name, subcommand_entity);
                }
            }
        }
    });

    return Test.run ();
}
