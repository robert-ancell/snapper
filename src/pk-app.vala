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
        get { return true; }
    }

    private Pk.Package package;
    private AppStream.Component component;

    public PkApp (Pk.Package package, AppStream.Component component)
    {
        this.package = package;
        this.component = component;
    }

    public override async void install (Cancellable? cancellable = null)
    {
    }

    public override async void remove (Cancellable? cancellable = null)
    {
    }
}