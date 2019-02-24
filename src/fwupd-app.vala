/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class FwupdApp : App
{
    public override string title {
        get {
            return device.get_name ();
        }
    }
    public override string publisher {
        get {
            return device.get_vendor ();
        }
    }
    public override string summary {
        get {
            return device.get_summary ();
        }
    }
    public override string description {
        get {
            return device.get_description ();
        }
    }
    /*public override string? icon_url {
        get {
        }
    }*/
    public override bool is_installed {
        get { return true; }
    }

    private Fwupd.Device device;

    public FwupdApp (Fwupd.Device device)
    {
        this.device = device;
    }

    public override string[] get_tracks () {
        return new string[] { "latest" };
    }

    public override string? get_channel_version (string track, string risk, string? branch = null) {
        if (track == "latest" && risk == "stable" && branch == null)
            return device.get_version ();
        return null;
    }
}
