vapi_sources = files(
  'config.vapi',
)

apa_code_sources = files (
  'alt/apt-cache.vala',
  'alt/apt-get.vala',

  'apa/list.vala',

  'flatpak/flatpak.vala',

  'snap/snap.vala',

  'apa.vala',
  'constants.vala',
  'command-args.vala',
  'main.vala',
  'spawn-command.vala',
  'utils.vala',
)

apa_sources = [
  vapi_sources,
  apa_code_sources,
]

apa_vala_args = [
  '--target-glib', '2.76',
  '--vapidir', meson.current_source_dir(),
]

apa_c_args = [
  '-include', 'config.h',
]

executable (
  meson.project_name(),
  apa_sources,
  include_directories: config_h_dir,
  vala_args: apa_vala_args,
  c_args: apa_c_args,
  dependencies: apa_dependencies,
  install: true,
)
