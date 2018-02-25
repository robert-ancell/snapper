/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class Snapper : Gtk.Application
{
    static bool show_version;
    public const OptionEntry[] options =
    {
        { "version", 'v', 0, OptionArg.NONE, ref show_version,
          /* Help string for command line --version flag */
          N_("Show release version"), null},
        { null }
    };

    private AppWindow window;
    private App? selected_app;

    public Snapper ()
    {
        Object (application_id: "io.snapcraft.Snapper");
        register_session = true;
    }

    public void show_snap (string name) {
        selected_app = new SnapApp (name);
    }

    public void show_package (string package) {
        // FIXME...
    }

    public override void startup ()
    {
        base.startup ();
        window = new AppWindow ();
        if (selected_app != null)
            window.show_details (selected_app);
        add_window (window);
    }

    public override void activate ()
    {
        base.activate ();
        window.show ();
    }

    public override void shutdown ()
    {
        base.shutdown ();
        window = null;
    }

    public static int main (string[] args)
    {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALE_DIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        var c = new OptionContext (/* Arguments and description for --help text */
                                   _("[URL] — Package manager"));
        c.add_main_entries (options, GETTEXT_PACKAGE);
        c.add_group (Gtk.get_option_group (true));
        try
        {
            c.parse (ref args);
        }
        catch (Error e)
        {
            stderr.printf ("%s\n", e.message);
            stderr.printf (/* Text printed out when an unknown command-line argument provided */
                           _("Run “%s --help” to see a full list of available command line options."), args[0]);
            stderr.printf ("\n");
            return Posix.EXIT_FAILURE;
        }
        if (show_version)
        {
            /* Note, not translated so can be easily parsed */
            stderr.printf ("snapper %s\n", VERSION);
            return Posix.EXIT_SUCCESS;
        }

        var app = new Snapper ();

        if (args.length > 1) {
            var url = args[1];
            if (url.has_prefix ("snap://")) {
                var name = url.substring ("snap://".length);
                app.show_snap (name);
            }
            else if (url.has_prefix ("apt://")) {
                var package = url.substring ("apt://".length);
                app.show_package (package);
            }
            else {
                stderr.printf (_("Unknown URL '%s'\n"), url);
                return Posix.EXIT_FAILURE;
            }
        }

        Gtk.init (ref args);
        return app.run ();
    }
}
