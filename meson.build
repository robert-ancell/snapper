project ('snapper', ['vala', 'c'],
         version: '0',
         license: 'GPLv3+',
         default_options: [
             'warning_level=1',
             'buildtype=debugoptimized',
         ],
         meson_version: '>= 0.37.1')

gnome = import ('gnome')
i18n = import ('i18n')

# Paths
localedir = join_paths (get_option ('prefix'), get_option ('localedir'))

# Dependencies
glib_dep = dependency ('glib-2.0')
gtk_dep = dependency ('gtk+-3.0')
snapd_glib_dep = dependency ('snapd-glib')

subdir ('src')
