project(
  'apa',
  ['vala', 'c'],
  version : '0.1.0',
  meson_version: '>= 1.0.0',
  license: 'GPL-3.0-or-later',
)

i18n = import('i18n')

glib = dependency ('glib-2.0', version: '>= 2.76')
gobject = dependency ('gobject-2.0')
gio = dependency ('gio-2.0')
gee = dependency ('gee-0.8')

apa_dependencies = [
  glib,
  gobject,
  gio,
  gee,
]

add_project_arguments(
  '-include', 'config.h',
  language: ['c']
)

add_project_arguments(
  '--target-glib', '2.76',
  '--vapidir', meson.current_source_dir(),
  language: ['vala']
)

version_suffix = ''

find_program ('apt-get', required: true)
find_program ('rpm', required: true)
find_program ('apt-repo', required: true)

if get_option('is_devel')
  find_program('git', required: true)
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD', check: false).stdout().strip()
  version_suffix = '-dev.' + vcs_tag
endif

conf = configuration_data()
conf.set_quoted('NAME', meson.project_name())
conf.set10('IS_DEVEL', get_option('is_devel'))
conf.set_quoted('VERSION', meson.project_version() + version_suffix)
conf.set_quoted('G_LOG_DOMAIN', meson.project_name())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
conf.set_quoted('GNOMELOCALEDIR', get_option('prefix') / get_option('localedir'))

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir ('po')
subdir ('src')
subdir ('test')
