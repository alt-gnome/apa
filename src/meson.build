vapi_sources = files(
  'config.vapi',
)

apa_no_main_code_sources = files (
  'apa/kernel/kernel.vala',
  'apa/kernel/list.vala',
  'apa/kernel/upgrade.vala',

  'apa/task/search.vala',
  'apa/task/show.vala',
  'apa/task/task.vala',

  'apa/update/update.vala',

  'apa/autoremove.vala',
  'apa/do.vala',
  'apa/info.vala',
  'apa/install.vala',
  'apa/moo.vala',
  'apa/reinstall.vala',
  'apa/remove.vala',
  'apa/source.vala',
  'apa/upgrade.vala',

  'apt/cache.vala',
  'apt/get.vala',
  'apt/repo.vala',

  'flatpak/flatpak.vala',

  'snap/snap.vala',

  'utils-commands/rpm.vala',
  'utils-commands/update-kernel.vala',

  'apa.vala',
  'command-handler.vala',
  'constants.vala',
  'error-detection.vala',
  'fuzzy-search.vala',
  'help.vala',
  'origin.vala',
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
