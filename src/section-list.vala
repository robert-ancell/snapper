/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class SectionList : Gtk.Box
{
    public signal void select_app (App app);

    private Gtk.FlowBox app_box;

    public SectionList (string label)
    {
        Object (orientation: Gtk.Orientation.VERTICAL, spacing: 12);

        var title_label = new Gtk.Label (label);
        title_label.visible = true;
        title_label.xalign = 0;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));
        attributes.insert (Pango.attr_scale_new (Pango.Scale.X_LARGE));
        title_label.attributes = attributes;
        pack_start (title_label, false, true, 0);

        app_box = new Gtk.FlowBox ();
        app_box.visible = true;
        app_box.homogeneous = true;
        app_box.row_spacing = 6;
        app_box.column_spacing = 6;
        app_box.activate_on_single_click = true;
        app_box.selection_mode = Gtk.SelectionMode.NONE;
        app_box.child_activated.connect ((child) => { select_app (((AppTile) child).app); });
        pack_start (app_box, false, true, 0);
    }

    public void add_app (App app)
    {
        var tile = new AppTile (app);
        tile.visible = true;
        tile.expand = false;
        app_box.add (tile);
    }
}
