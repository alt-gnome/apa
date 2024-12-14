vapi_sources = files(
  'config.vapi',
)

apa_no_main_code_sources = files (
  'apa/config/get.vala',
  'apa/config/list.vala',
  'apa/config/reset.vala',
  'apa/config/set.vala',

  'apa/kernel/list.vala',
  'apa/kernel/upgrade.vala',

  'apa/repo/add-aides.vala',
  'apa/repo/add.vala',
  'apa/repo/list.vala',
  'apa/repo/remove-aides.vala',
  'apa/repo/remove.vala',

  'apa/task/add.vala',
  'apa/task/install.vala',
  'apa/task/list.vala',
  'apa/task/search.vala',
  'apa/task/show.vala',

  'apa/autoremove.vala',
  'apa/do.vala',
  'apa/info.vala',
  'apa/install.vala',
  'apa/list.vala',
  'apa/moo.vala',
  'apa/reinstall.vala',
  'apa/remove.vala',
  'apa/search-file.vala',
  'apa/search.vala',
  'apa/source.vala',
  'apa/update.vala',
  'apa/upgrade.vala',

  'apt/cache.vala',
  'apt/get.vala',
  'apt/repo.vala',

  'data/cache-data.vala',
  'data/commands-data.vala',
  'data/config-data.vala',
  'data/descriptions.vala',
  'data/get-data.vala',
  'data/repo-data.vala',
  'data/rpm-data.vala',
  'data/search-file-data.vala',
  'data/task-data.vala',
  'data/update-kernel-data.vala',

  'entities/arg-option.vala',
  'entities/command-entity.vala',
  'entities/config-entity.vala',
  'entities/option-entity.vala',

  'flatpak/flatpak.vala',

  'snap/snap.vala',

  'utils-commands/rpm.vala',
  'utils-commands/update-kernel.vala',

  'apa.vala',
  'args-handler.vala',
  'command.vala',
  'config-manager.vala',
  'constants.vala',
  'error-detection.vala',
  'fuzzy-search.vala',
  'help.vala',
  'spawn-command.vala',
  'utils.vala',
)

apa_no_main_sources = [
  vapi_sources,
  apa_no_main_code_sources,
]

apa_sources = [
  apa_no_main_sources,
  files (
    'main.vala'
  )
]

executable (
  meson.project_name(),
  apa_sources,
  include_directories: config_h_dir,
  dependencies: apa_dependencies,
  install: true,
)
