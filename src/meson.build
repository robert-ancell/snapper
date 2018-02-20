snapper = executable ('snapper',
                      [ 'config.vapi',
                        'snapper.vala' ],
                      dependencies: [ gtk_dep, snapd_glib_dep ],
                      vala_args: [ '--pkg=posix' ],
                      c_args: [ '-DVERSION="@0@"'.format (meson.project_version ()),
                                '-DGETTEXT_PACKAGE="snapper"',
                                '-DLOCALE_DIR="@0@"'.format (localedir) ],
                      install: true )
