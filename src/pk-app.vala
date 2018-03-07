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
    public override uint64 download_size {
        get {
            if (details == null)
                return 0;
            return details.size;
        }
    }
    public override bool is_installed {
        get { return package != null; }
    }
    public override double progress {
        get { return _progress; }
    }
    public override string? odrs_id {
        get {
            return component.get_id ();
        }
    }

    private Pk.Package? package;
    private Pk.Details? details;
    private AppStream.Component component;
    private double _progress = -1.0;

    public PkApp (Pk.Package? package, Pk.Details? details, AppStream.Component component)
    {
        this.package = package;
        this.details = details;
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

        /* Lookup package */
        string[] ids = {};
        try {
            var filter = Pk.Bitfield.from_enums (Pk.Filter.NOT_INSTALLED, Pk.Filter.ARCH, Pk.Filter.NOT_SOURCE, Pk.Filter.NEWEST);
            var results = yield task.resolve_async (filter, { component.get_pkgname () }, cancellable, progress_cb);
            var packages = results.get_package_array ();
            for (var i = 0; i < packages.length; i++)
                ids += packages[i].get_id ();
        }
        catch (Error e) {
            warning ("Failed to lookup package %s: %s", component.get_pkgname (), e.message);
            return;
        }

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
            yield task.remove_packages_async (ids, true, true, cancellable, progress_cb);
        }
        catch (Error e) {
            warning ("Failed to remove %s: %s", component.get_pkgname (), e.message);
        }
    }

    private void progress_cb (Pk.Progress progress, Pk.ProgressType type)
    {
        if (type == Pk.ProgressType.PERCENTAGE) {
            _progress = progress.percentage / 100.0;
            progress_changed ();
        }
    }
}
