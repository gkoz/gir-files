#!/bin/bash
set -x -e

# Remove all fields from FcFontMap. Its' parent_instance field is broken and we don't need the type anyway.
# Replace cairo_font_type_t with enums::FontType as well.
xmlstarlet ed -P -L \
	-d '//_:class[@name="FcFontMap"]/_:field' \
	-u '//*[@c:type="cairo_font_type_t"]/@c:type' -v enums::FontType \
	PangoCairo-1.0.gir

# Remove Int32 alias because it misses c:type, it not like anyone actually cares about it.
xmlstarlet ed -P -L \
	-d '//_:alias[@name="Int32"]' \
	freetype2-2.0.gir

# Change FontType glib:type to FontType.
# Replace cairo_font_type_t with enums::FontType as well.
xmlstarlet ed -P -L \
	-u '//_:enumeration[@name="FontType"]/@glib:type-name' -v FontType \
	-u '//*[@c:type="cairo_font_type_t"]/@c:type' -v enums::FontType \
	cairo-1.0.gir

# gir uses error domain to find quark function corresponding to given error enum,
# but in this case it happens to be named differently, i.e., as g_option_error_quark.
xmlstarlet ed -P -L \
	-u '//*[@glib:error-domain="g-option-context-error-quark"]/@glib:error-domain' -v g-option-error-quark \
	GLib-2.0.gir


# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:class[@name="IconTheme"]/_:method//_:parameter[@name="icon_names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="IconTheme"]/_:method[@name="get_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "gchar***" \
	-u '//_:class[@name="IconTheme"]/_:method[@name="set_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "const gchar**" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_boolean_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gboolean*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_double_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gdouble*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_integer_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gint*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_locale_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	GLib-2.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="values"]/_:array/@c:type' -v "GValue*" \
	-u '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	-u '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="names"]/_:array/@c:type' -v "const char**" \
	-u '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	GObject-2.0.gir

# incorrectly marked as transfer-none GitLab issue #197
xmlstarlet ed -P -L \
	-u '//_:class[@name="Binding"]/_:method[@name="unbind"]//_:instance-parameter[@name="binding"]/@transfer-ownership' -v "full" \
	GObject-2.0.gir

# incorrect type
xmlstarlet ed -P -L \
	-d '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/_:type' \
	-s '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]' -t 'elem' -n 'array' -v '' \
	-i '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/array' -t 'attr' -n 'length' -v '6' \
	-i '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/array' -t 'attr' -n 'zero-terminated' -v '0' \
	-i '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/array' -t 'attr' -n 'c:type' -v 'const guint8*' \
	-s '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/array' -t 'elem' -n 'type' \
	-i '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/array/type' -t 'attr' -n 'name' -v 'guint8' \
	-i '//_:function[@name="property_change"]/_:parameters/_:parameter[@name="data"]/array/type' -t 'attr' -n 'c:type' -v 'guint8' \
	Gdk-3.0.gir
