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
    private LazyIcon icon_image;
    private Gtk.Label title_label;
    private Gtk.Label developer_label;

    public string title {
        set { title_label.label = value; }
    }
    public string developer {
        set { developer_label.label = value; }
    }
    public string icon_url {
        set { icon_image.url = value; }
    }

    public AppRow ()
    {
        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        hbox.visible = true;
        add (hbox);

        icon_image = new LazyIcon ();
        icon_image.visible = true;
        hbox.pack_start (icon_image, false, false, 0);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.visible = true;
        hbox.pack_start (box, true, true, 0);

        title_label = new Gtk.Label ("");
        title_label.visible = true;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));
        title_label.attributes = attributes;
        box.pack_start (title_label, false, false, 0);

        developer_label = new Gtk.Label ("");
        developer_label.visible = true;
        box.pack_start (developer_label, false, false, 0);
    }
}
