project(
  'apa',
  ['vala', 'c'],
  version : '0.1.0',
  meson_version: '>= 0.62.0',
  license: 'GPL-3.0-or-later',
)

i18n = import('i18n')

glib = dependency ('glib-2.0', version: '>= 2.76')
gobject = dependency ('gobject-2.0')
gio = dependency ('gio-2.0')

apa_dependencies = [
  glib,
  gobject,
  gio
]

version_suffix = ''

if get_option('is_devel')
  find_program('git', required: true)
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
  version_suffix = '-dev.@0@'.format (vcs_tag)
endif

conf = configuration_data()
conf.set_quoted('NAME', meson.project_name())
conf.set10('IS_DEVEL', get_option('is_devel'))
conf.set_quoted('VERSION', '@0@@1@'.format (meson.project_version(), version_suffix))
conf.set_quoted('G_LOG_DOMAIN', meson.project_name())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir ('po')
subdir ('src')
