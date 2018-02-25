/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class HomePage : Gtk.Box
{
    public signal void select_app (App app);

    private Gtk.SearchEntry search_entry;
    private Gtk.Stack stack;
    private PromotionPage promotion_page;
    private SearchPage search_page;

    public signal void search (string text);

    public HomePage ()
    {
        Object (orientation: Gtk.Orientation.VERTICAL);

        var search_bar = new Gtk.SearchBar ();
        search_bar.visible = true;
        search_bar.search_mode_enabled = true;
        pack_start (search_bar, false, true, 0);

        search_entry = new Gtk.SearchEntry ();
        search_entry.visible = true;
        search_entry.width_chars = 40;
        search_entry.search_changed.connect (() => {
            if (search_entry.text == "")
                stack.visible_child = promotion_page;
            else {
                stack.visible_child = search_page;
                search (search_entry.text);
            }
        });
        search_bar.add (search_entry);

        stack = new Gtk.Stack ();
        stack.visible = true;
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        pack_start (stack, true, true, 0);

        promotion_page = new PromotionPage ();
        promotion_page.visible = true;
        promotion_page.select_app.connect ((app) => select_app (app));
        stack.add (promotion_page);

        search_page = new SearchPage ();
        search_page.visible = true;
        search_page.margin = 12;
        search_page.select_app.connect ((app) => select_app (app));
        stack.add (search_page);
    }

    public void clear_search ()
    {
        search_page.clear ();
    }

    public void add_search_app (App app)
    {
        search_page.add_app (app);
    }
}
