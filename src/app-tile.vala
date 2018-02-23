/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AppTile : Gtk.FlowBoxChild
{
    public App app;
    private AsyncImage icon_image;
    private Gtk.Label title_label;

    public AppTile (App app)
    {
        this.app = app;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        box.visible = true;
        add (box);

        icon_image = new AsyncImage ();
        icon_image.visible = true;
        box.pack_start (icon_image, false, false, 0);

        title_label = new Gtk.Label ("");
        title_label.visible = true;
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.max_width_chars = 10;
        box.pack_start (title_label, false, false, 0);

        app.changed.connect (() => { refresh_metadata (); });
        refresh_metadata ();
    }

    private void refresh_metadata ()
    {
        title_label.label = app.title;
        icon_image.url = app.icon_url;
    }
}
