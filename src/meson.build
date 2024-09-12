vapi_sources = files(
  'config.vapi',
)

apa_no_main_code_sources = files (
  'alt/apt-cache.vala',
  'alt/apt-get.vala',

  'apa/rpm.vala',

  'flatpak/flatpak.vala',

  'snap/snap.vala',

  'apa.vala',
  'constants.vala',
  'command-args.vala',
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
