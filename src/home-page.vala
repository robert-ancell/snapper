/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class HomePage : Gtk.ScrolledWindow
{
    public signal void select_app (App app);

    private Gtk.Box section_box;

    public HomePage ()
    {
        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        section_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        section_box.visible = true;
        add (section_box);
    }

    public SectionList add_section (string name)
    {
        var section = new SectionList (name);
        section.visible = true;
        section.select_app.connect ((app) => { select_app (app); });
        section_box.pack_start (section, false, true, 0);
        return section;
    }
}
