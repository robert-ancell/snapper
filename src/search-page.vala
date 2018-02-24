/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class SearchPage : Gtk.Box
{
    public signal void select_app (App app);

    private Gtk.SearchEntry search_entry;
    private Gtk.ListBox app_list;

    public signal void search (string text);

    public SearchPage ()
    {
        Object (orientation: Gtk.Orientation.VERTICAL);

        search_entry = new Gtk.SearchEntry ();
        search_entry.visible = true;
        search_entry.search_changed.connect (() => { search (search_entry.text); });
        pack_start (search_entry, false, false, 0);

        var search_scroll = new Gtk.ScrolledWindow (null, null);
        search_scroll.visible = true;
        search_scroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        pack_start (search_scroll, true, true, 0);

        app_list = new Gtk.ListBox ();
        app_list.visible = true;
        app_list.margin = 12;
        app_list.activate_on_single_click = true;
        app_list.selection_mode = Gtk.SelectionMode.NONE;
        app_list.row_activated.connect ((row) => { select_app (((AppRow) row).app); });
        search_scroll.add (app_list);
    }

    public void reset ()
    {
        search_entry.grab_focus ();
    }

    public void clear ()
    {
        app_list.forall ((element) => app_list.remove (element));
    }

    public void add_app (App app)
    {
        var row = new AppRow (app);
        row.visible = true;
        row.margin = 6;
        app_list.add (row);
    }
}
