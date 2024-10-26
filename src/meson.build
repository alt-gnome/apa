vapi_sources = files(
  'config.vapi',
)

apa_no_main_code_sources = files (
  'apt/apt-cache.vala',
  'apt/apt-get.vala',

  'apa/info.vala',
  'apa/install.vala',
  'apa/moo.vala',
  'apa/remove.vala',
  'apa/source.vala',
  'apa/update.vala',
  'apa/upgrade.vala',

  'flatpak/flatpak.vala',

  'rpm/rpm.vala',

  'snap/snap.vala',

  'apa.vala',
  'constants.vala',
  'error-detection.vala',
  'fuzzy-search.vala',
  'help.vala',
  'command-args.vala',
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
