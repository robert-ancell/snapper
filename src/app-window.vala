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
    private Gtk.Stack stack;
    private Gtk.RadioButton home_button;
    private Gtk.RadioButton installed_button;
    private Gtk.RadioButton updates_button;
    private Gtk.Button back_button;
    private HomePage home_page;
    private InstalledPage installed_page;
    private UpdatesPage updates_page;
    private DetailsPage details_page;
    private Cancellable? search_cancellable;
    private Gtk.Widget? back_page = null;
    private AppStream.Pool pool;

    public AppWindow ()
    {
        set_size_request (800, 600);

        var header_bar = new Gtk.HeaderBar ();
        header_bar.visible = true;
        header_bar.title = _("Snapper");
        header_bar.show_close_button = true;
        set_titlebar (header_bar);

        var page_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        page_box.visible = true;
        page_box.homogeneous = true;
        page_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        header_bar.set_custom_title (page_box);

        home_button = new Gtk.RadioButton.with_label (null, "Home");
        home_button.visible = true;
        home_button.set_mode (false);
        home_button.active = true;
        home_button.clicked.connect (() => { if (home_button.active) show_home (); });
        page_box.pack_start (home_button, false, true, 0);

        installed_button = new Gtk.RadioButton.with_label (home_button.get_group (), "Installed");
        installed_button.visible = true;
        installed_button.set_mode (false);
        installed_button.clicked.connect (() => { if (installed_button.active) show_installed (); });
        page_box.pack_start (installed_button, false, true, 0);

        updates_button = new Gtk.RadioButton.with_label (installed_button.get_group (), "Updates");
        updates_button.visible = true;
        updates_button.set_mode (false);
        updates_button.clicked.connect (() => { if (updates_button.active) show_updates (); });
        page_box.pack_start (updates_button, false, true, 0);

        back_button = new Gtk.Button.from_icon_name ("back");
        back_button.clicked.connect (() => { stack.visible_child = back_page; back_page = null; update_state (); });
        header_bar.pack_start (back_button);

        stack = new Gtk.Stack ();
        stack.visible = true;
        add (stack);

        home_page = new HomePage ();
        home_page.visible = true;
        home_page.search.connect ((text) => { search (text); });
        home_page.select_app.connect ((app) => { show_details (app); });
        stack.add (home_page);

        installed_page = new InstalledPage ();
        installed_page.visible = true;
        installed_page.select_app.connect ((app) => { show_details (app); });
        stack.add (installed_page);

        updates_page = new UpdatesPage ();
        updates_page.visible = true;
        updates_page.select_app.connect ((app) => { show_details (app); });
        stack.add (updates_page);

        details_page = new DetailsPage ();
        details_page.visible = true;
        stack.add (details_page);

        load_installed.begin ();
        load_appstream.begin ();
        load_fwupd.begin ();
    }

    private async void load_installed ()
    {
        var client = new Snapd.Client ();
        try {
            var snaps = yield client.list_async (null);
            for (var i = 0; i < snaps.length; i++) {
                var app = new SnapApp (snaps[i].name, snaps[i], null);
                installed_page.add_app (app);
            }
        }
        catch (Error e) {
            warning ("Failed to get installed snaps: %s", e.message);
        }
    }

    private async void load_appstream (Cancellable? cancellable = null)
    {
        pool = new AppStream.Pool ();

        SourceFunc callback = load_appstream.callback;
        ThreadFunc<void*> run = () => {
            try {
                pool.load ();
            }
            catch (Error e) {
                warning ("Failed to load appstream pool: %s", e.message); // FIXME: probably not safe to do in a thread
            }
            Idle.add ((owned) callback);
            return null;
        };
        new Thread<void*> (null, run);

        yield;

        var task = new Pk.Task ();
        var missing_packages = "";
        try {
            var filter = Pk.Bitfield.from_enums (Pk.Filter.INSTALLED);
            var results = yield task.get_packages_async (filter, cancellable, () => {});
            if (results.get_error_code () == null) {
                var packages = results.get_package_array ();
                for (var i = 0; i < packages.length; i++) {
                    var package = packages[i];
                    var component = find_component (package.get_name ());
                    if (component != null) {
                        var app = new PkApp (package, null, component);
                        installed_page.add_app (app);
                    }
                    else
                        missing_packages += " " + package.get_name ();
                }
            }
        }
        catch (Error e) {
            warning ("Failed to get installed packages: %s", e.message);
        }
        if (missing_packages != "")
            warning ("Failed to find AppStream data for packages:%s", missing_packages);

        missing_packages = "";
        try {
            var filter = Pk.Bitfield.from_enums (Pk.Filter.NONE);
            var results = yield task.get_updates_async (filter, cancellable, () => {});
            if (results.get_error_code () == null) {
                var packages = results.get_package_array ();

                string[] package_ids = {};
                for (var i = 0; i < packages.length; i++)
                    package_ids += packages[i].package_id;
                var details_results = yield task.get_details_async (package_ids, cancellable, () => {});
                var details_array = details_results.get_details_array ();

                for (var i = 0; i < packages.length; i++) {
                    var package = packages[i];
                    var component = find_component (package.get_name ());
                    Pk.Details? details = null;
                    for (var j = 0; j < details_array.length; j++) {
                        if (details_array[j].package_id == package.package_id) {
                            details = details_array[j];
                            break;
                        }
                    }
                    if (component != null) {
                        var app = new PkApp (package, details, component);
                        updates_page.add_app (app);
                    }
                    else
                        missing_packages += " " + package.get_name ();
                }
            }

        }
        catch (Error e) {
            warning ("Failed to get installed packages: %s", e.message);
        }
        if (missing_packages != "")
            warning ("Failed to find AppStream data for packages:%s", missing_packages);
    }

    private AppStream.Component? find_component (string pkgname)
    {
        var components = pool.get_components ();
        for (var i = 0; i < components.length; i++) {
            var component = components[i];
            if (component.get_pkgname () == pkgname)
                return component;
        }

        return null;
    }

    private async void load_fwupd (Cancellable? cancellable = null)
    {
        var client = new Fwupd.Client ();
        try {
            client.connect (cancellable);
            var devices = client.get_devices ();
            for (var i = 0; i < devices.length; i++) {
                var app = new FwupdApp (devices[i]);
                installed_page.add_app (app);
            }
        }
        catch (Error e)
        {
            warning ("Failed to connect to fwupd: %s", e.message);
            return;
        }
    }

    private void search (string text)
    {
        if (search_cancellable != null)
            search_cancellable.cancel ();
        search_cancellable = new Cancellable ();

        home_page.clear_search ();
        do_snapd_search.begin (text);
        do_appstream_search.begin (text);
    }

    private async void do_snapd_search (string text)
    {
        var client = new Snapd.Client ();
        try {
            string suggested_currency;
            var snaps = yield client.find_async (Snapd.FindFlags.NONE, text, search_cancellable, out suggested_currency);
            for (var i = 0; i < snaps.length; i++) {
                var app = new SnapApp (snaps[i].name, null, snaps[i]);
                home_page.add_search_app (app);
            }
        }
        catch (Error e)
        {
            if (e is IOError.CANCELLED)
                return;
            warning ("Failed to search: %s", e.message);
        }
    }

    private async void do_appstream_search (string text)
    {
        // Short searches are too expensive...
        if (text.length < 3)
            return;

        // FIXME: pool might not yet be loaded
        var components = pool.search (text);
        for (var i = 0; i < components.length; i++) {
            var component = components[i];
            var app = new PkApp (null, null, component);
            home_page.add_search_app (app);
        }
    }

    private void show_home ()
    {
        back_page = null;
        stack.visible_child = home_page;
        update_state ();
    }

    private void show_installed ()
    {
        back_page = null;
        stack.visible_child = installed_page;
        update_state ();
    }

    private void show_updates ()
    {
        back_page = null;
        stack.visible_child = updates_page;
        update_state ();
    }

    public void show_details (App app)
    {
        details_page.set_app (app);
        back_page = stack.visible_child;
        stack.visible_child = details_page;
        update_state ();
    }

    private void update_state ()
    {
        back_button.visible = back_page != null;
        if (stack.visible_child == home_page) {
            home_button.active = true;
            installed_button.active = false;
            updates_button.active = false;
        }
        if (stack.visible_child == installed_page) {
            home_button.active = false;
            installed_button.active = true;
            updates_button.active = false;
        }
        if (stack.visible_child == updates_page) {
            home_button.active = false;
            installed_button.active = false;
            updates_button.active = true;
        }
    }
}
