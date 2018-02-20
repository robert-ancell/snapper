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
    public AppRow (string title, string developer, string? icon)
    {
        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        hbox.visible = true;
        add (hbox);

        var icon_image = new Gtk.Image ();
        icon_image.visible = true;
        hbox.pack_start (icon_image, false, false, 0);
        if (icon != null) {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", icon);
            try {
                var stream = session.send (message);
                var pixbuf = new Gdk.Pixbuf.from_stream_at_scale (stream, 64, 64, true);
                icon_image.set_from_pixbuf (pixbuf);
            }
            catch (Error e) {
                warning ("Failed to download icon: %s", icon);
            }
        }
        stderr.printf ("icon=%s\n", icon);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.visible = true;
        hbox.pack_start (box, true, true, 0);

        var title_label = new Gtk.Label (title);
        title_label.visible = true;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));
        title_label.attributes = attributes;
        box.pack_start (title_label, false, false, 0);

        var developer_label = new Gtk.Label (developer);
        developer_label.visible = true;
        box.pack_start (developer_label, false, false, 0);
    }
}
