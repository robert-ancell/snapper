/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class PromotionPage : Gtk.ScrolledWindow
{
    public signal void select_app (App app);

    private Gtk.Box section_box;

    public PromotionPage ()
    {
        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        section_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        section_box.visible = true;
        section_box.margin = 12;
        add (section_box);

        load_sections.begin ();
    }

    private async void load_sections ()
    {
        var client = new Snapd.Client ();

        string[] sections;
        try {
            sections = yield client.get_sections_async (null);
        }
        catch (Error e) {
            warning ("Failed to get sections: %s", e.message);
            return;
        }

        var section_lists = new HashTable<string, SectionList> (str_hash, str_equal);
        foreach (var section_name in sections)
            section_lists.insert (section_name, add_section (section_name));

        foreach (var section_name in sections) {
            try {
                string suggested_currency;
                var snaps = yield client.find_section_async (Snapd.FindFlags.NONE, section_name, null, null, out suggested_currency);
                for (var i = 0; i < snaps.length; i++) {
                    var app = new SnapApp (snaps[i].name, null, snaps[i]);
                    section_lists.lookup (section_name).add_app (app);
                }
            }
            catch (Error e) {
                warning ("Failed to get section %s: %s", section_name, e.message);
            }
        }
    }

    private SectionList add_section (string name)
    {
        var section = new SectionList (name);
        section.visible = true;
        section.select_app.connect ((app) => { select_app (app); });
        section_box.pack_start (section, false, true, 0);
        return section;
    }
}
