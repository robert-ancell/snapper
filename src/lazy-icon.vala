/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class LazyIcon : Gtk.Image {
    private string? url;

    public LazyIcon (string? url) {
        this.url = url;
        load.begin ();
    }
    
    private async void load ()
    {
        if (url == null)
            return;

        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);
        try {
            var stream = yield session.send_async (message);
            var pixbuf = yield new Gdk.Pixbuf.from_stream_at_scale_async (stream, 64, 64, true);
            set_from_pixbuf (pixbuf);
        }
        catch (Error e) {
            warning ("Failed to download icon: %s", url);
        }
    }
}
