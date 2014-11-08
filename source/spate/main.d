module spate.main;

import std.stdio;
import std.c.process;

import gtk.Builder;
import gtk.Button;
import gtk.HBox;
import gtk.Main;
import gtk.Paned;
import gtk.VPaned;
import gtk.Label;
import gtk.Widget;
import gtk.Window;
import gobject.ObjectG;
import gobject.Type;

import kdaf.bus;
import spate.model.colour;
import spate.view.colourview;
import spate.controller.colourcontroller;

void show()
{
    string layout = import("MainWindow.glade");

    Builder g = new Builder();
    if( ! g.addFromString(layout, layout.length) )
    {
        writefln("Oops, could not create Glade object, check your glade file ;)");
        exit(1);
    }
    Window w = cast(Window)g.getObject("window1");
    if (w !is null)
    {
        w.setTitle("This is a glade window");
        w.addOnHide( delegate void(Widget aux){ Main.quit(); } );
    }
    else
    {
        writefln("No window?");
        exit(1);
    }

    auto bus = new Bus();

    auto cv = new ColourView(bus);
    auto cc = new ColourController(bus);
    cv.colour = new Colour(255, 0, 0);

    ObjectG object = g.getObject("vpaned1");
    Paned vpaned1 = cast(Paned) object;
    vpaned1.add2(cv);
    w.showAll();
}
