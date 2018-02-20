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

    public Snapper ()
    {
        Object (application_id: "io.snapcraft.Snapper");
        register_session = true;
    }

    public override void startup ()
    {
        base.startup ();
        window = new AppWindow ();
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
                                   _("Snap package manager"));
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

        Gtk.init (ref args);

        var app = new Snapper ();
        return app.run ();
    }
}
