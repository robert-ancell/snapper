/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AppRow : Gtk.ListBoxRow
{
    public App app;
    private AsyncImage icon_image;
    private Gtk.Label title_label;
    private Gtk.Label developer_label;

    public AppRow (App app)
    {
        this.app = app;

        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        hbox.visible = true;
        add (hbox);

        int width, height;
        Gtk.icon_size_lookup (Gtk.IconSize.DIALOG, out width, out height);
        icon_image = new AsyncImage (width, height, "package");
        icon_image.visible = true;
        hbox.pack_start (icon_image, false, false, 0);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.visible = true;
        hbox.pack_start (box, true, true, 0);

        title_label = new Gtk.Label ("");
        title_label.visible = true;
        title_label.xalign = 0;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));
        title_label.attributes = attributes;
        box.pack_start (title_label, false, false, 0);

        developer_label = new Gtk.Label ("");
        developer_label.visible = true;
        developer_label.xalign = 0;
        box.pack_start (developer_label, false, false, 0);

        app.changed.connect (() => { refresh_metadata (); });
        refresh_metadata ();
    }

    private void refresh_metadata ()
    {
        title_label.label = app.title;
        developer_label.label = app.developer;
        icon_image.url = app.icon_url;
    }
}
