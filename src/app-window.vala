/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AppWindow : Gtk.ApplicationWindow
{
    private Gtk.Stack stack;
    private Gtk.Button back_button;
    private Gtk.ListBox app_list;
    private LazyIcon icon_image;
    private Gtk.Label title_label;
    private Gtk.Label summary_label;
    private Gtk.Label description_label;

    public AppWindow ()
    {
        var header_bar = new Gtk.HeaderBar ();
        header_bar.visible = true;
        header_bar.title = _("Snapper");
        header_bar.show_close_button = true;
        set_titlebar (header_bar);

        back_button = new Gtk.Button.from_icon_name ("back");
        back_button.visible = true;
        back_button.clicked.connect (() => { stack.set_visible_child_name ("installed"); });
        header_bar.pack_start (back_button);

        stack = new Gtk.Stack ();
        stack.visible = true;
        add (stack);

        app_list = new Gtk.ListBox ();
        app_list.visible = true;
        app_list.activate_on_single_click = true;
        app_list.row_activated.connect ((row) => { show_details (((AppRow) row).app); });
        stack.add_named (app_list, "installed");

        var grid = new Gtk.Grid ();
        grid.visible = true;
        stack.add_named (grid, "details");

        icon_image = new LazyIcon ();
        icon_image.visible = true;
        icon_image.expand = false;
        grid.attach (icon_image, 0, 0, 1, 2);

        title_label = new Gtk.Label ("");
        title_label.visible = true;
        title_label.hexpand = true;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_scale_new (Pango.Scale.LARGE));
        title_label.attributes = attributes;
        grid.attach (title_label, 1, 0, 1, 1);

        summary_label = new Gtk.Label ("");
        summary_label.visible = true;
        grid.attach (summary_label, 1, 1, 1, 1);

        description_label = new Gtk.Label ("");
        description_label.visible = true;
        description_label.wrap = true;
        grid.attach (description_label, 0, 2, 2, 1);

        var client = new Snapd.Client ();
        try {
            var snaps = client.list_sync ();
            for (var i = 0; i < snaps.length; i++) {
                var app = new App (snaps[i], null);
                var row = new AppRow (app);
                row.visible = true;
                app_list.add (row);
            }
        }
        catch (Error e) {
        }
    }

    public void show_details (App app)
    {
        title_label.label = app.title;
        summary_label.label = app.summary;
        description_label.label = app.description;
        icon_image.url = app.icon_url;
        stack.set_visible_child_name ("details");
    }
}
