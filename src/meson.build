vapi_sources += files(
  'config.vapi',
)

vala_no_main_sources = files (
  'apa/config/config-get.vala',
  'apa/config/config-list.vala',
  'apa/config/config-reset.vala',
  'apa/config/config-set.vala',

  'apa/kernel/kernel-list.vala',
  'apa/kernel/kernel-upgrade.vala',

  'apa/repo/repo-add-aides.vala',
  'apa/repo/repo-add.vala',
  'apa/repo/repo-list.vala',
  'apa/repo/repo-remove-aides.vala',
  'apa/repo/repo-remove.vala',

  'apa/task/task-add.vala',
  'apa/task/task-install.vala',
  'apa/task/task-list-packages.vala',
  'apa/task/task-search.vala',
  'apa/task/task-show.vala',

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

  'apt/apt-cache.vala',
  'apt/apt-get.vala',
  'apt/apt-repo.vala',

  'cachier/cachier.vala',
  'cachier/package-list.vala',
  'cachier/package.vala',
  'cachier/rpm-evr.vala',

  'data/cache-data.vala',
  'data/commands-data.vala',
  'data/config-data.vala',
  'data/descriptions.vala',
  'data/get-data.vala',
  'data/list-data.vala',
  'data/repo-data.vala',
  'data/rpm-data.vala',
  'data/search-data.vala',
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
  # 'progress.vala',
  'spawn-command.vala',
  'utils.vala',
)

no_main_sources = [
  vapi_sources,
  vala_no_main_sources,
]

sources = [
  no_main_sources,
  files (
    'main.vala'
  )
]

executable (
  meson.project_name(),
  sources,
  include_directories: config_h_dir,
  dependencies: apa_dependencies,
  install: true,
)
