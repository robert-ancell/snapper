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
    private Gtk.ListBox search_list;
    private Cancellable? search_cancellable;

    public SearchPage ()
    {
        Object (orientation: Gtk.Orientation.VERTICAL);

        search_entry = new Gtk.SearchEntry ();
        search_entry.visible = true;
        search_entry.search_changed.connect (() => { do_search.begin (search_entry.text); });
        pack_start (search_entry, false, false, 0);

        var search_scroll = new Gtk.ScrolledWindow (null, null);
        search_scroll.visible = true;
        search_scroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        pack_start (search_scroll, true, true, 0);

        search_list = new Gtk.ListBox ();
        search_list.visible = true;
        search_list.activate_on_single_click = true;
        search_list.row_activated.connect ((row) => { select_app (((AppRow) row).app); });
        search_scroll.add (search_list);
    }

    public void reset ()
    {
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
                var app = new SnapApp (null, snaps[i]);
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
