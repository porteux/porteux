/***************************************************************************
 *   Copyright (C) 2007 by PCMan (Hong Jen Yee)   *
 *   pcman.tw@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include "image-view.h"
#include <math.h>

static void image_view_finalize(GObject *iv);

static void image_view_clear( ImageView* iv );
static void calc_image_area( ImageView* iv );

#if GTK_CHECK_VERSION(3, 0, 0)
static void paint(  ImageView* iv, GdkRectangle* invalid_rect, GdkInterpType type, cairo_t* cr );

static void image_view_paint(  ImageView* iv, cairo_t* cr );

static void on_get_preferred_width( GtkWidget* widget, gint* minimal_width, gint* natural_width );
static void on_get_preferred_height( GtkWidget* widget, gint* minimal_height, gint* natural_height );
static gboolean on_draw_event(GtkWidget* widget, cairo_t* cr);

#else // GTK2
static gboolean on_idle( ImageView* iv );
static void paint(  ImageView* iv, GdkRectangle* invalid_rect, GdkInterpType type );

static void image_view_paint(  ImageView* iv, GdkEventExpose* evt );

static void on_size_request( GtkWidget* w, GtkRequisition* req );
static gboolean on_expose_event( GtkWidget* widget, GdkEventExpose* evt );
#endif


static void on_size_allocate( GtkWidget* widget, GtkAllocation    *allocation );

G_DEFINE_TYPE( ImageView, image_view, GTK_TYPE_MISC );

void image_view_init( ImageView* iv )
{
    iv->pix = NULL;
    iv->scale =  1.0;
    iv->interp_type = GDK_INTERP_BILINEAR;
    iv->idle_handler = 0;
#if GTK_CHECK_VERSION(2, 18, 0)
    gtk_widget_set_can_focus((GtkWidget*)iv, TRUE );
    gtk_widget_set_app_paintable((GtkWidget*)iv, TRUE );
#else
    GTK_WIDGET_SET_FLAGS( (GtkWidget*)iv, GTK_CAN_FOCUS | GTK_APP_PAINTABLE );
#endif
}

void image_view_class_init( ImageViewClass* klass )
{
    GObjectClass * obj_class;
    GtkWidgetClass *widget_class;

    obj_class = ( GObjectClass * ) klass;
//    obj_class->set_property = _set_property;
//   obj_class->get_property = _get_property;
    obj_class->finalize = image_view_finalize;

    widget_class = GTK_WIDGET_CLASS ( klass );
#if GTK_CHECK_VERSION(3, 0, 0)
    widget_class->get_preferred_width = on_get_preferred_width;
    widget_class->get_preferred_height = on_get_preferred_height;
    widget_class->draw = on_draw_event;
#else // GTK2
    widget_class->size_request = on_size_request;
    widget_class->expose_event = on_expose_event;
#endif
    widget_class->size_allocate = on_size_allocate;


/*
    // set up scrolling support
    klass->set_scroll_adjustments = set_adjustments;
    widget_class->set_scroll_adjustments_signal =
                g_signal_new ( "set_scroll_adjustments",
                        G_TYPE_FROM_CLASS (obj_class),
                        G_SIGNAL_RUN_LAST,
                        G_STRUCT_OFFSET (ImageView::Class, set_scroll_adjustments),
                        NULL, NULL,
                        _marshal_VOID__OBJECT_OBJECT,
                        G_TYPE_NONE, 2,
                        GTK_TYPE_ADJUSTMENT, GTK_TYPE_ADJUSTMENT);
*/
}

void image_view_finalize(GObject *iv)
{
    image_view_clear( (ImageView*)iv );
/*
    if( vadj )
        g_object_unref( vadj );
    if( hadj )
        g_object_unref( hadj );
*/
}

GtkWidget* image_view_new()
{
    return (GtkWidget*)g_object_new ( IMAGE_VIEW_TYPE, NULL );
}

// End of GObject-related stuff

void image_view_set_adjustments( ImageView* iv, GtkAdjustment* h, GtkAdjustment* v )
{
    if( iv->hadj != h )
    {
        if( iv->hadj )
            g_object_unref( iv->hadj );
        if( G_LIKELY(h) )
        {
    #if GTK_CHECK_VERSION( 2, 10, 0 )
            iv->hadj = (GtkAdjustment*)g_object_ref_sink( h );
    #else
            iv->hadj = (GtkAdjustment*)h;
            gtk_object_sink( (GtkObject*)h );
    #endif
        }
        else
            iv->hadj = NULL;
    }
    if( iv->vadj != v )
    {
        if( iv->vadj )
            g_object_unref( iv->vadj );
        if( G_LIKELY(v) )
        {
#if GTK_CHECK_VERSION( 2, 10, 0 )
            iv->vadj = (GtkAdjustment*)g_object_ref_sink( v );
#else
            iv->vadj = (GtkAdjustment*)v;
            gtk_object_sink( (GtkObject*)v );
#endif
        }
        else
            iv->vadj = NULL;
    }
}

#if GTK_CHECK_VERSION(3, 0, 0)

void on_get_preferred_width( GtkWidget* widget, gint* minimal_width, gint* natural_width )
{
    ImageView* iv = (ImageView*)widget;
    *minimal_width = *natural_width = iv->img_area.width;
}

void on_get_preferred_height( GtkWidget* widget, gint* minimal_height, gint* natural_height )
{
    ImageView* iv = (ImageView*)widget;
    *minimal_height = *natural_height = iv->img_area.height;
}

#else // GTK2

void on_size_request( GtkWidget* w, GtkRequisition* req )
{
    ImageView* iv = (ImageView*)w;

    w->requisition.width = iv->img_area.width;
    w->requisition.height = iv->img_area.height;

    GTK_WIDGET_CLASS(image_view_parent_class)->size_request (w, req);
}

#endif

void on_size_allocate( GtkWidget* widget, GtkAllocation   *allocation )
{
    GTK_WIDGET_CLASS(image_view_parent_class)->size_allocate( widget, allocation );
    ImageView* iv = (ImageView*)widget;

    iv->allocation = *allocation;

/*
    if( !iv->buffer || allocation->width != widget->allocation.width ||
        allocation->height != widget->allocation.height )
    {
        if( iv->buffer )
            g_object_unref( iv->buffer );
        iv->buffer = gdk_pixmap_new( (GdkDrawable*)widget->window,
                                        allocation->width, allocation->height, -1 );
        g_debug( "off screen buffer created: %d x %d", allocation->width, allocation->height );
    }
*/
    calc_image_area( iv );
}

#if GTK_CHECK_VERSION(3, 0, 0)

static cairo_region_t *
eel_cairo_get_clip_region (cairo_t *cr)
/* From nautilus http://git.gnome.org/browse/nautilus/tree/eel/eel-canvas.c */
{
        cairo_rectangle_list_t *list;
        cairo_region_t *region;
        int i;

        list = cairo_copy_clip_rectangle_list (cr);
        if (list->status == CAIRO_STATUS_CLIP_NOT_REPRESENTABLE) {
                cairo_rectangle_int_t clip_rect;

                cairo_rectangle_list_destroy (list);

                if (!gdk_cairo_get_clip_rectangle (cr, &clip_rect))
                        return NULL;
                return cairo_region_create_rectangle (&clip_rect);
        }


        region = cairo_region_create ();
        for (i = list->num_rectangles - 1; i >= 0; --i) {
                cairo_rectangle_t *rect = &list->rectangles[i];
                cairo_rectangle_int_t clip_rect;

                clip_rect.x = floor (rect->x);
                clip_rect.y = floor (rect->y);
                clip_rect.width = ceil (rect->x + rect->width) - clip_rect.x;
                clip_rect.height = ceil (rect->y + rect->height) - clip_rect.y;

                if (cairo_region_union_rectangle (region, &clip_rect) != CAIRO_STATUS_SUCCESS) {
                        cairo_region_destroy (region);
                        region = NULL;
                        break;
                }
        }

        cairo_rectangle_list_destroy (list);
        return region;
}

static gboolean on_draw_event( GtkWidget* widget, cairo_t *cr )
{

    ImageView* iv = (ImageView*)widget;
    if ( gtk_widget_get_mapped(widget) )
        image_view_paint( iv, cr );
    return FALSE;

}

void image_view_paint( ImageView* iv, cairo_t *cr )
{
    if( iv->pix )
    {
        cairo_region_t * region = eel_cairo_get_clip_region(cr);
        int n_rects = cairo_region_num_rectangles(region);

        int i;
        for( i = 0; i < n_rects; ++i )
        {
            cairo_rectangle_int_t rectangle;
            cairo_region_get_rectangle(region, i, &rectangle);
            paint( iv, &rectangle, iv->interp_type, cr );
        }

        cairo_region_destroy (region);
    }
}
#else // GTK2

gboolean on_expose_event( GtkWidget* widget, GdkEventExpose* evt )
{
    ImageView* iv = (ImageView*)widget;
    if( GTK_WIDGET_MAPPED (widget) )
        image_view_paint( iv, evt );
    return FALSE;
}

void image_view_paint( ImageView* iv, GdkEventExpose* evt )
{
/*
    GtkWidget* widget = (GtkWidget*)iv;
    if( cached )
    {
//        gdk_draw_drawable( drawable, widget->style->fg_gc[GTK_STATE_NORMAL], buffer,
//                         0, 0,  );
        return;
    }
*/

    if( iv->pix )
    {
        GdkRectangle* rects = NULL;
        int i, n_rects = 0;
        gdk_region_get_rectangles( evt->region, &rects, &n_rects );

        for( i = 0; i < n_rects; ++i )
        {
            // GdkRectangle& rect = rects[i];
            paint( iv, rects + i, iv->interp_type );
        }
        g_free( rects );

        if( 0 == iv->idle_handler )
            iv->idle_handler = g_idle_add( (GSourceFunc)on_idle, iv );
    }
}

#endif
void image_view_clear( ImageView* iv )
{
    if( iv->idle_handler )
    {
        g_source_remove( iv->idle_handler );
        iv->idle_handler = 0;
    }

    if( iv->pix )
    {
        g_object_unref( iv->pix );
        iv->pix = NULL;
        calc_image_area( iv );
    }
/*
    if( buffer )
    {
        g_object_unref( buffer );
        buffer = NULL;
    }
*/
}

void image_view_set_pixbuf( ImageView* iv, GdkPixbuf* pixbuf )
{
    if( pixbuf != iv->pix )
    {
        image_view_clear( iv );
        if( G_LIKELY(pixbuf) )
            iv->pix = (GdkPixbuf*)g_object_ref( pixbuf );
        calc_image_area( iv );
        gtk_widget_queue_resize( (GtkWidget*)iv );
//        gtk_widget_queue_draw( (GtkWidget*)iv);
    }
}

void image_view_set_scale( ImageView* iv, gdouble new_scale, GdkInterpType type )
{
    if( new_scale == iv->scale )
        return;
//    gdouble factor = new_scale / iv->scale;
    iv->scale = new_scale;
    if( iv->pix )
    {
        calc_image_area( iv );
        gtk_widget_queue_resize( (GtkWidget*)iv );
//        gtk_widget_queue_draw( (GtkWidget*)iv );

/*
    // adjust scroll bars
        int vis_w = ((GtkWidget*)iv)->allocation.width;
        if( hadj && vis_w < img_area.width )
        {
            hadj->upper = img_area.width;
            hadj->page_size = vis_w;
            gdouble new_w = (hadj->value + vis_w / 2) * factor - vis_w/2;
            hadj->value = CLAMP(  new_w, 0, hadj->upper - hadj->page_size );
            gtk_adjustment_value_changed( hadj );
        }
        int vis_h = ((GtkWidget*)iv)->allocation.height;
        if( vadj && vis_h < img_area.height )
        {
            vadj->upper = img_area.height;
            vadj->page_size = vis_h;
            gdouble new_h = (vadj->value + vis_h / 2) * factor - vis_h/2;
            vadj->value = CLAMP(  new_h, 0, vadj->upper - vadj->page_size );
            gtk_adjustment_value_changed( vadj );
        }
*/
    }
}

#if GTK_CHECK_VERSION(3, 0, 0)
#else // GTK2
gboolean on_idle( ImageView* iv )
{
    GDK_THREADS_ENTER();

    // FIXME: redraw the whole window everytime is very inefficient
    // There must be some way to optimize iv. :-(
    GdkRectangle rect;

    if( G_LIKELY(iv->hadj) )
    {
        rect.x = (int)gtk_adjustment_get_value(iv->hadj);
#if GTK_CHECK_VERSION(2, 14, 0)
        rect.width = (int)gtk_adjustment_get_page_size(iv->hadj);
#else
        rect.width = (int)iv->hadj->page_size;
#endif
    }
    else
    {
        rect.x = iv->allocation.x;
        rect.width = iv->allocation.width;
    }

    if( G_LIKELY(iv->vadj) )
    {
        rect.y = (int)gtk_adjustment_get_value(iv->vadj);
#if GTK_CHECK_VERSION(2, 14, 0)
        rect.height = (int)gtk_adjustment_get_page_size(iv->vadj);
#else
        rect.height = (int)iv->vadj->page_size;
#endif
    }
    else
    {
        rect.y = iv->allocation.y;
        rect.height = iv->allocation.height;
    }

    paint( iv, &rect, iv->interp_type );

    GDK_THREADS_LEAVE();

    iv->idle_handler = 0;
    return FALSE;
}
#endif

void calc_image_area( ImageView* iv )
{
    if( G_LIKELY( iv->pix ) )
    {
        GtkAllocation allocation = iv->allocation;
        iv->img_area.width = (int)floor( ((gdouble)gdk_pixbuf_get_width( iv->pix )) * iv->scale + 0.5 );
        iv->img_area.height = (int)floor( ((gdouble)gdk_pixbuf_get_height( iv->pix )) * iv->scale + 0.5 );
        // g_debug( "width=%d, height=%d", width, height );

        int x_offset = 0, y_offset = 0;
        if( iv->img_area.width < allocation.width )
            x_offset = (int)floor( ((gdouble)(allocation.width - iv->img_area.width)) / 2 + 0.5);
        if( iv->img_area.height < allocation.height )
            y_offset = (int)floor( ((gdouble)(allocation.height - iv->img_area.height)) / 2 + 0.5);

        iv->img_area.x = x_offset;
        iv->img_area.y = y_offset;
    }
    else
    {
        iv->img_area.x = iv->img_area.y = iv->img_area.width = iv->img_area.height = 0;
    }
}

#if GTK_CHECK_VERSION(3, 0, 0)
void paint( ImageView* iv, GdkRectangle* invalid_rect, GdkInterpType type, cairo_t* cr )
#else // GTK2
void paint( ImageView* iv, GdkRectangle* invalid_rect, GdkInterpType type )
#endif
{
    GdkRectangle rect;
    if( ! gdk_rectangle_intersect( invalid_rect, &iv->img_area, &rect ) )
        return;

    int dest_x;
    int dest_y;

    GdkPixbuf* src_pix = NULL;
    GdkPixbuf* scaled_pix = NULL;

    dest_x = rect.x;
    dest_y = rect.y;

    rect.x -= iv->img_area.x;
    rect.y -= iv->img_area.y;

    int src_x = (int)floor( ((gdouble)rect.x) / iv->scale + 0.5 );
    int src_y = (int)floor( ((gdouble)rect.y) / iv->scale + 0.5 );
    int src_w = (int)floor( ((gdouble)rect.width) / iv->scale + 0.5 );
    int src_h = (int)floor( ((gdouble)rect.height) / iv->scale + 0.5 );
    if( src_y > gdk_pixbuf_get_height( iv->pix ) )
        src_y = gdk_pixbuf_get_height( iv->pix );
    if( src_x + src_w > gdk_pixbuf_get_width( iv->pix ) )
        src_w = gdk_pixbuf_get_width( iv->pix ) - src_x;
    if( src_y + src_h > gdk_pixbuf_get_height( iv->pix ) )
        src_h = gdk_pixbuf_get_height( iv->pix ) - src_y;
    //g_debug("orig src: x=%d, y=%d, w=%d, h=%d",
    //        src_x, src_y, src_w, src_h );

    if ((src_w > 0) && (src_h > 0))
    {
        src_pix = gdk_pixbuf_new_subpixbuf( iv->pix, src_x, src_y,  src_w, src_h );
        scaled_pix = gdk_pixbuf_scale_simple( src_pix, rect.width, rect.height, type );
        g_object_unref( src_pix );
        src_pix = scaled_pix;
    }

    if( G_LIKELY(src_pix) )
    {
        GtkWidget* widget = (GtkWidget*)iv;
#if GTK_CHECK_VERSION(3, 0, 0)
#else // GTK2
        cairo_t *cr = gdk_cairo_create (gtk_widget_get_window(widget));
#endif
        gdk_cairo_set_source_pixbuf (cr, src_pix, dest_x, dest_y);
        cairo_paint (cr);
#if GTK_CHECK_VERSION(3, 0, 0)
#else // GTK2
        cairo_destroy (cr);
#endif

        g_object_unref( src_pix );
    }
}

void image_view_get_size( ImageView* iv, int* w, int* h )
{
    if( G_LIKELY(w) )
        *w = iv->img_area.width;
    if( G_LIKELY(h) )
        *h = iv->img_area.height;
}
