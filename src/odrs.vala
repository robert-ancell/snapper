/*
 * Copyright (C) 2018 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class ODRSClient : Object
{
    private string user_hash;
    private string distro;
    private string locale;

    public ODRSClient ()
    {
        distro = get_os_release ("NAME");
        user_hash = get_user_hash ();
        locale = get_locale ();
    }

    public async GenericArray<ODRSReview> get_reviews (string app_id, string? version, int64 limit)
    {
        var reviews = new GenericArray<ODRSReview> ();

        var session = new Soup.Session ();
        var message = new Soup.Message ("POST", "https://odrs.gnome.org/1.0/reviews/api/fetch");

        var builder = new Json.Builder ();
        builder.begin_object ();
        builder.set_member_name ("user_hash");
        builder.add_string_value (user_hash);
        builder.set_member_name ("app_id");
        builder.add_string_value (app_id);
        builder.set_member_name ("locale");
        builder.add_string_value (locale);
        builder.set_member_name ("distro");
        builder.add_string_value (distro);
        builder.set_member_name ("version");
        builder.add_string_value (version != null ? version : "");
        builder.set_member_name ("limit");
        builder.add_int_value (limit);
        builder.end_object ();
        var generator = new Json.Generator ();
        generator.root = builder.get_root ();
        size_t length;
        var json_text = generator.to_data (out length);
        message.set_request ("application/json; charset=utf-8", Soup.MemoryUse.COPY, json_text.data);

        InputStream input;
        try {
            input = yield session.send_async (message);
        }
        catch (Error e) {
            warning ("Failed to get reviews: %s", e.message);
            return reviews;
        }

        if (message.status_code != Soup.Status.OK) {
            warning ("Failed to get reviews, server returned %u: %s", message.status_code, message.reason_phrase);
            return reviews;
        }

        var parser = new Json.Parser ();
        try {
            parser.load_from_stream (input);
        }
        catch (Error e) {
            warning ("Failed to parse ODRS response: %s", e.message);
        }
        var root = parser.get_root ();
        if (root.get_node_type () != Json.NodeType.ARRAY) {
            warning ("Failed to get reviews, server returned non JSON array");
            return reviews;
        }

        var array = root.get_array ();
        for (var i = 0; i < array.get_length (); i++) {
            var element = array.get_element (i);
            if (element.get_node_type () != Json.NodeType.OBJECT) {
                warning ("Failed to get reviews...");
                return reviews;
            }

            var review = element.get_object ();
            var r = new ODRSReview ();
            r.date_created = new DateTime.from_unix_utc (review.get_int_member ("date_created"));
            r.user_display = review.get_string_member ("user_display");
            r.version = review.get_string_member ("version");
            r.rating = review.get_int_member ("rating");
            r.summary = review.get_string_member ("summary");
            r.description = review.get_string_member ("description");
            reviews.add (r);
        }

        return reviews;
    }

    private string? get_user_hash ()
    {
        string machine_id;
        try {
            FileUtils.get_contents ("/etc/machine-id", out machine_id);
        }
        catch (Error e) {
            warning ("Failed to determine machine ID: %s", e.message);
            return null;
        }

        var salted = "gnome-software[%s:%s]".printf (Environment.get_user_name (), machine_id);
        return Checksum.compute_for_string (ChecksumType.SHA1, salted);
    }

    private string? get_os_release (string field)
    {
        string contents;
        try {
            FileUtils.get_contents ("/etc/os-release", out contents);
        }
        catch (Error e) {
            warning ("Failed to get OS information: %s", e.message);
            return null;
        }

        var lines = contents.split ("\n");
        foreach (var line in lines) {
            var tokens = line.split ("=", 2);
            if (tokens.length < 2)
                continue;
            var key = tokens[0];
            var value = tokens[1];
            if (key == field) {
                if (value.has_prefix ("\"")) {
                    var end = value.index_of ("\"", 1);
                    if (end > 0)
                        return value.slice (1, end);
                }
                else
                    return value.strip ();
            }
        }

        return null;
    }

    private string get_locale ()
    {
        var locale = Intl.setlocale (LocaleCategory.MESSAGES, null);
        if (locale.has_suffix (".UTF-8"))
            return locale.slice (0, -".UTF-8".length);
        else if (locale.has_suffix (".utf8"))
            return locale.slice (0, -".utf8".length);
        else
            return locale;
    }
}

public class ODRSReview : Object
{
    public DateTime date_created;
    public string user_display;
    public string version;
    public int64 rating;
    public string summary;
    public string description;
}
