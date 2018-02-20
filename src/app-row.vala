/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AppRow : Gtk.ListBoxRow
{
    public AppRow (string title)
    {
        var title_label = new Gtk.Label (title);
        title_label.visible = true;
        add (title_label);
    }
}
