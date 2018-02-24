/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class PkApp : App
{
    public override string name {
        get {
            return component.get_pkgname ();
        }
    }
    public override string title {
        get {
            return component.get_name ();
        }
    }
    public override string developer {
        get {
            return component.get_developer_name ();
        }
    }
    public override string summary {
        get {
            return component.get_summary ();
        }
    }
    public override string description {
        get {
            return component.get_description ();
        }
    }
    public override string? icon_url {
        get {
            var icons = component.get_icons ();
            if (icons.length == 0)
                return null;
            return icons[0].get_url ();
        }
    }
    public override bool is_installed {
        get { return package != null; }
    }

    private Pk.Package? package;
    private AppStream.Component component;

    public PkApp (Pk.Package? package, AppStream.Component component)
    {
        this.package = package;
        this.component = component;
    }

    public override string[] get_tracks () {
        return new string[] { "latest" };
    }

    public override string? get_channel_version (string track, string risk, string? branch = null) {
        if (track == "latest" && risk == "stable" && branch == null)
            return package.get_version ();
        return null;
    }

    public override string[] get_screenshots ()
    {
        var screenshots = component.get_screenshots ();
        string[] urls = {};
        for (var i = 0; i < screenshots.length; i++) {
            urls += screenshots[i].get_images ()[0].get_url ();
        }
        return urls;
    }

    public override async void install (Cancellable? cancellable = null)
    {
        var task = new Pk.Task ();
        string[] ids = { component.get_pkgname () };
        try {
            yield task.install_packages_async (ids, cancellable, (progress, type) => {});
        }
        catch (Error e) {
            warning ("Failed to install %s: %s", component.get_pkgname (), e.message);
        }
    }

    public override async void remove (Cancellable? cancellable = null)
    {
        var task = new Pk.Task ();
        string[] ids = { component.get_pkgname () }; // FIXME: Id contains more than just pkgname
        try {
            yield task.remove_packages_async (ids, true, true, cancellable, (progress, type) => {});
        }
        catch (Error e) {
            warning ("Failed to install %s: %s", component.get_pkgname (), e.message);
        }
    }
}
