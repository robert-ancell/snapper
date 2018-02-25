/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class DetailsPage : Gtk.ScrolledWindow
{
    public signal void select_app (App app);

    private AsyncImage icon_image;
    private Gtk.Label title_label;
    private Gtk.Label summary_label;
    private Gtk.Button install_button;
    private Gtk.ProgressBar install_progress;
    private Gtk.ScrolledWindow screenshot_scroll;
    private Gtk.Label description_label;
    private Gtk.Box channel_box;
    private App? selected_app;

    public DetailsPage ()
    {
        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        var grid = new Gtk.Grid ();
        grid.visible = true;
        grid.margin = 12;
        grid.row_spacing = 12;
        add (grid);

        int width, height;
        Gtk.icon_size_lookup (Gtk.IconSize.DIALOG, out width, out height);
        icon_image = new AsyncImage (width, height, "package");
        icon_image.visible = true;
        icon_image.expand = false;
        grid.attach (icon_image, 0, 0, 1, 2);

        title_label = new Gtk.Label ("");
        title_label.visible = true;
        title_label.hexpand = true;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_scale_new (Pango.Scale.LARGE));
        title_label.attributes = attributes;
        grid.attach (title_label, 1, 0, 1, 1);

        summary_label = new Gtk.Label ("");
        summary_label.visible = true;
        grid.attach (summary_label, 1, 1, 1, 1);

        var install_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        install_box.visible = true;
        grid.attach (install_box, 0, 2, 2, 1);

        install_button = new Gtk.Button.with_label (_("Install"));
        install_button.clicked.connect (() => { install_remove_app.begin (); });
        install_button.visible = true;
        install_box.pack_start (install_button, false, true, 0);

        install_progress = new Gtk.ProgressBar ();
        install_box.pack_start (install_progress, true, true, 0);

        screenshot_scroll = new Gtk.ScrolledWindow (null, null);
        screenshot_scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER);
        grid.attach (screenshot_scroll, 0, 4, 2, 1);

        description_label = new Gtk.Label ("");
        description_label.visible = true;
        description_label.wrap = true;
        grid.attach (description_label, 0, 5, 2, 1);

        channel_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        channel_box.visible = true;
        grid.attach (channel_box, 0, 6, 2, 1);
    }

    public void set_app (App app)
    {
        selected_app = app;
        if (screenshot_scroll.get_children () != null)
            screenshot_scroll.remove (screenshot_scroll.get_children ().nth_data (0));
        screenshot_scroll.visible = false;
        selected_app.changed.connect (() => { refresh_selected_metadata (); }); // FIXME: Disconnect when changes
        selected_app.progress_changed.connect (() => { install_progress.fraction = selected_app.progress; }); // FIXME: Disconnect when changes
        refresh_selected_metadata ();
    }

    private void refresh_selected_metadata ()
    {
        if (selected_app.is_installed)
            install_button.label = _("Remove");
        else
            install_button.label = _("Install");
        title_label.label = selected_app.title;
        summary_label.label = selected_app.summary;
        description_label.label = selected_app.description;
        icon_image.url = selected_app.icon_url;

        var screenshot_urls = selected_app.get_screenshots ();
        if (screenshot_urls.length != 0 && !screenshot_scroll.visible) {
            screenshot_scroll.visible = true;
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            box.visible = true;
            screenshot_scroll.add (box);
            foreach (var url in screenshot_urls) {
                var image = new AsyncImage (350, 350, "image-loading-symbolic");
                image.visible = true;
                image.url = url;
                box.pack_start (image, false, false, 0);
            }
        }

        if (channel_box.get_children () != null)
            channel_box.remove (channel_box.get_children ().nth_data (0));

        var channel_grid = new Gtk.Grid ();
        channel_grid.visible = true;
        channel_grid.row_spacing = 6;
        channel_grid.column_spacing = 6;
        channel_box.add (channel_grid);

        var channel_label = new Gtk.Label (_("Channel"));
        channel_label.visible = true;
        channel_label.xalign = 0;
        var attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));
        channel_label.attributes = attributes;
        channel_grid.attach (channel_label, 0, 0, 1, 1);

        var version_label = new Gtk.Label (_("Version"));
        version_label.visible = true;
        attributes = new Pango.AttrList ();
        attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));
        version_label.attributes = attributes;
        channel_grid.attach (version_label, 1, 0, 1, 1);

        var tracks = selected_app.get_tracks ();
        var channel_count = 0;
        if (tracks.length > 0) {
            foreach (var track in tracks) {
                string[] risks = { "stable", "candidate", "beta", "edge" };
                foreach (var risk in risks) {
                    var version = selected_app.get_channel_version (track, risk);
                    var name = track == "latest" ? risk : "%s/%s".printf (track, risk);

                    var name_label = new Gtk.Label (name);
                    name_label.visible = true;
                    name_label.xalign = 0;
                    channel_grid.attach (name_label, 0, channel_count + 1, 1, 1);

                    var v_label = new Gtk.Label (version != null ? version : "↑");
                    v_label.visible = true;
                    channel_grid.attach (v_label, 1, channel_count + 1, 1, 1);

                    channel_count++;
                }
            }
        }
    }

    public async void install_remove_app ()
    {
        install_button.sensitive = false;
        install_progress.visible = true;
        if (!selected_app.is_installed) {
            install_button.label = _("Installing…");
            yield selected_app.install ();
        }
        else {
            install_button.label = _("Removing…");
            yield selected_app.remove ();
        }
        install_progress.visible = false;
        install_button.sensitive = true;
        refresh_selected_metadata ();
    }
}
