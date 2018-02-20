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
    private Gtk.ListBox app_list;

    public AppWindow ()
    {
        app_list = new Gtk.ListBox ();
        app_list.visible = true;
        add (app_list);

        var client = new Snapd.Client ();
        try {
            var snaps = client.list_sync ();
            for (var i = 0; i < snaps.length; i++) {
                var snap = snaps[i];

                string? icon = null;
                try {
                    var store_snaps = client.find_sync (Snapd.FindFlags.MATCH_NAME, snap.name, null);
                    icon = store_snaps[0].icon;
                }
                catch (Error e) {
                    warning ("Failed to get store info: %s", e.message);
                }

                var row = new AppRow (snap.title, snap.developer, icon);
                row.visible = true;
                app_list.add (row);
            }
        }
        catch (Error e) {
        }
    }
}
