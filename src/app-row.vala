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
    public AppRow (string title, string developer)
    {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.visible = true;
        add (box);

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
