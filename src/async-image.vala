/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AsyncImage : Gtk.Stack {
    private string url_;
    public string url {
        get { return url_; }
        set {
            if (url_ == value)
                return;
            url_ = value;
            visible_child = default_image;
            load.begin ();
        }
    }

    private int width;
    private int height;
    private Gtk.Image default_image;
    private Gtk.Image image;

    public AsyncImage (int width, int height, string default_icon_name) {
        transition_type = Gtk.StackTransitionType.CROSSFADE;

        this.width = width;
        this.height = height;

        set_size_request (width, height);

        default_image = new Gtk.Image ();
        default_image.visible = true;
        default_image.set_from_icon_name (default_icon_name, Gtk.IconSize.DIALOG);
        add (default_image);

        image = new Gtk.Image ();
        image.visible = true;
        add (image);
    }
    
    private async void load ()
    {
        if (url == null)
            return;

        if (url.has_prefix ("file://")) {
            var filename = url.substring ("file://".length);

            int width, height;
            Gtk.icon_size_lookup (Gtk.IconSize.DIALOG, out width, out height);
            try {
                var pixbuf = new Gdk.Pixbuf.from_file_at_size (filename, width, height);
                image.set_from_pixbuf (pixbuf);
                visible_child = image;
            }
            catch (Error e) {
                warning ("Failed to load icon: %s", url);
            }

            return;
        }

        if (url.has_prefix ("http://") || url.has_prefix ("https://")) {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);
            try {
                var stream = yield session.send_async (message);
                var pixbuf = yield new Gdk.Pixbuf.from_stream_at_scale_async (stream, width, height, true);
                image.set_from_pixbuf (pixbuf);
                visible_child = image;
            }
            catch (Error e) {
                warning ("Failed to download icon from %s: %s", url, e.message);
            }

            return;
        }
    }
}
