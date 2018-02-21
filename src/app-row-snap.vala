/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AppRowSnap : AppRow
{
    public AppRowSnap (Snapd.Snap local_snap, Snapd.Snap? store_snap)
    {
        title = local_snap.title;
        developer = local_snap.developer;
        if (store_snap == null)
            load_store_metadata.begin (local_snap.name);
    }

    private async void load_store_metadata (string name)
    {
        var client = new Snapd.Client ();
        try {
            string suggested_currency;
            var snaps = yield client.find_async (Snapd.FindFlags.MATCH_NAME, name, null, out suggested_currency);
            if (snaps.length == 0)
                return;
            var snap = snaps[0];
            icon_url = snap.icon;
        }
        catch (Error e) {
            warning ("Failed to load store information on %s: %s", name, e.message);
        }
    }
}
