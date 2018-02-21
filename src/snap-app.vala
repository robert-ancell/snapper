/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class SnapApp : App
{
    public override string name {
        get {
            if (local_snap != null)
                return local_snap.name;
            else
                return store_snap.name;
        }
    }
    public override string title {
        get {
            if (local_snap != null)
                return local_snap.title;
            else
                return store_snap.title;
        }
    }
    public override string developer {
        get {
            if (local_snap != null)
                return local_snap.developer;
            else
                return store_snap.developer;
        }
    }
    public override string summary {
        get {
            if (local_snap != null)
                return local_snap.summary;
            else
                return store_snap.summary;
        }
    }
    public override string description {
        get {
            if (local_snap != null)
                return local_snap.description;
            else
                return store_snap.description;
        }
    }
    public override string? icon_url {
        get {
            if (local_snap != null && local_snap.icon != null)
                return local_snap.icon;
            if (store_snap != null && store_snap.icon != null)
                return store_snap.icon;
            return null;
        }
    }
    public override bool is_installed {
        get { return local_snap != null; }
    }

    private Snapd.Snap? local_snap;
    private Snapd.Snap? store_snap;    

    public SnapApp (Snapd.Snap? local_snap, Snapd.Snap? store_snap)
    {
        if (local_snap == null) {
            var client = new Snapd.Client ();
            try {
                local_snap = client.list_one_sync (store_snap.name);
            }
            catch (Error e) {
                warning ("Failed to get installed state for snap %s: %s", store_snap.name, e.message);
            }
        }

        this.local_snap = local_snap;
        this.store_snap = store_snap;
        if (store_snap == null)
            load_store_metadata.begin (local_snap.name);
    }

    public override async void install (Cancellable? cancellable = null)
    {
        var client = new Snapd.Client ();
        try {
            yield client.install2_async (Snapd.InstallFlags.NONE, store_snap.name, null, null, () => {}, cancellable);
        }
        catch (Error e) {
            warning ("Failed to install %s: %s", store_snap.name, e.message);
            return;
        }

        try {
            local_snap = client.list_one_sync (store_snap.name);
        }
        catch (Error e) {
            warning ("Failed to get installed state for snap %s: %s", store_snap.name, e.message);
        }

        changed ();
    }

    public override async void remove (Cancellable? cancellable = null)
    {
        var client = new Snapd.Client ();
        try {
            yield client.remove_async (local_snap.name, () => {}, cancellable);
        }
        catch (Error e) {
            warning ("Failed to remove %s: %s", store_snap.name, e.message);
            return;
        }
        local_snap = null;

        changed ();
    }

    private async void load_store_metadata (string name)
    {
        var client = new Snapd.Client ();
        try {
            string suggested_currency;
            var snaps = yield client.find_async (Snapd.FindFlags.MATCH_NAME, name, null, out suggested_currency);
            if (snaps.length == 0)
                return;
            this.store_snap = snaps[0];
            changed ();
        }
        catch (Error e) {
            warning ("Failed to load store information on %s: %s", name, e.message);
        }
    }
}