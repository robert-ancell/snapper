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
    private Gtk.Button search_button;
    private Gtk.ListBox app_list;
    private Gtk.SearchEntry search_entry;
    private Cancellable? search_cancellable;
    private Gtk.ListBox search_list;
    private AsyncImage icon_image;
    private Gtk.Label title_label;
    private Gtk.Label summary_label;
    private Gtk.Button install_button;
    private Gtk.Label description_label;
    private App? selected_app;

    public AppWindow ()
    {
        var header_bar = new Gtk.HeaderBar ();
        header_bar.visible = true;
        header_bar.title = _("Snapper");
        header_bar.show_close_button = true;
        set_titlebar (header_bar);

        back_button = new Gtk.Button.from_icon_name ("back");
        back_button.clicked.connect (() => { show_installed (); });
        header_bar.pack_start (back_button);

        search_button = new Gtk.Button.from_icon_name ("search");
        search_button.visible = true;
        search_button.clicked.connect (() => { show_search (); });
        header_bar.pack_end (search_button);

        stack = new Gtk.Stack ();
        stack.visible = true;
        add (stack);

        var installed_scroll = new Gtk.ScrolledWindow (null, null);
        installed_scroll.visible = true;
        installed_scroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        stack.add_named (installed_scroll, "installed");

        app_list = new Gtk.ListBox ();
        app_list.visible = true;
        app_list.activate_on_single_click = true;
        app_list.row_activated.connect ((row) => { show_details (((AppRow) row).app); });
        installed_scroll.add (app_list);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.visible = true;
        stack.add_named (box, "search");

        search_entry = new Gtk.SearchEntry ();
        search_entry.visible = true;
        search_entry.search_changed.connect (() => { do_search.begin (search_entry.text); });
        box.pack_start (search_entry, false, false, 0);

        var search_scroll = new Gtk.ScrolledWindow (null, null);
        search_scroll.visible = true;
        search_scroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        box.pack_start (search_scroll, true, true, 0);

        search_list = new Gtk.ListBox ();
        search_list.visible = true;
        search_list.activate_on_single_click = true;
        search_list.row_activated.connect ((row) => { show_details (((AppRow) row).app); });
        search_scroll.add (search_list);

        var grid = new Gtk.Grid ();
        grid.visible = true;
        stack.add_named (grid, "details");

        icon_image = new AsyncImage ();
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

        install_button = new Gtk.Button.with_label (_("Install"));
        install_button.clicked.connect (() => { install_remove_app.begin (); });
        install_button.visible = true;
        grid.attach (install_button, 0, 2, 1, 1);

        description_label = new Gtk.Label ("");
        description_label.visible = true;
        description_label.wrap = true;
        grid.attach (description_label, 0, 3, 2, 1);

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
            warning ("Failed to get installed snaps: %s", e.message);
        }
    }

    public void show_installed ()
    {
        back_button.visible = false;
        search_button.visible = true;
        stack.set_visible_child_name ("installed");
    }

    public void show_details (App app)
    {
        selected_app = app;
        back_button.visible = true;
        search_button.visible = false;
        selected_app.changed.connect (() => { refresh_selected_metadata (); }); // FIXME: Disconnect when changes
        refresh_selected_metadata ();
        stack.set_visible_child_name ("details");
    }

    private void refresh_selected_metadata ()
    {
        if (selected_app.is_installed)
            install_button.label = _("Remove");
        else
            install_button.label = _("Install");
        title_label.label = selected_app.title;
        summary_label.label = selected_app.summary;
        description_label.label = selected_app.description;
        icon_image.url = selected_app.icon_url;
    }

    public async void install_remove_app ()
    {
        install_button.sensitive = false;
        if (!selected_app.is_installed)
            yield selected_app.install ();
        else
            yield selected_app.remove ();
        install_button.sensitive = true;
    }

    public void show_search ()
    {
        back_button.visible = true;
        stack.set_visible_child_name ("search");
        search_entry.grab_focus ();
    }

    private async void do_search (string text)
    {
        if (search_cancellable != null)
            search_cancellable.cancel ();
        search_cancellable = new Cancellable ();
        search_list.forall ((element) => search_list.remove (element));
        var client = new Snapd.Client ();
        try {
            string suggested_currency;
            var snaps = yield client.find_async (Snapd.FindFlags.NONE, text, search_cancellable, out suggested_currency);
            for (var i = 0; i < snaps.length; i++) {
                var app = new App (null, snaps[i]);
                var row = new AppRow (app);
                row.visible = true;
                search_list.add (row);
            }
        }
        catch (Error e)
        {
            warning ("Failed to search: %s\n", e.message);
        }
    }
}
