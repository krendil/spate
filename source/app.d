import std.stdio;
import gtk.Main;
import spate.main;

void main(string[] args)
{
    Main.initMultiThread(args);

    spate.main.show();

    Main.run();
}


