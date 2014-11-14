module spate.view.palettelistview;

debug import std.stdio;
import std.signals;

import cairo.Context;

import gtk.Button;
import gtk.DrawingArea;
import gtk.Label;
import gtk.ListStore;
import gtk.VBox;

import gtk.HandleBox;

import kdaf.bus;
import kdaf.view;

import spate.model.palette;
import spate.model.colour;


class PaletteListView : VBox {

mixin View;

private:

    Palette _palette;

    Bus commandBus;

    PaletteListColourView[Colour] listItems;

    @GtkChild{
        Label nameLabel;

        VBox colourListBox;
        Button addColourButton;
    }


public:

    this(Bus commandBus) {
        super(true, 0);
        buildFromGlade();

        addColourButton.addOnClicked(&onAddColour);

        this.commandBus = commandBus;
    }


    void palette(Palette palette) {
        if(_palette !is null) {
            _palette.onChange.disconnect!"onPaletteChanged"(this);
            _palette.onColourAdded.disconnect!"onPaletteColourAdded"(this);
            _palette.onColourRemoved.disconnect!"onPaletteColourRemoved"(this);

            foreach( c; _palette.colours ) {
                onPaletteColourRemoved(c);
            }
        }
        this._palette = palette;
        if(_palette !is null) {
            _palette.onChange.connect!"onPaletteChanged"(this);
            _palette.onColourAdded.connect!"onPaletteColourAdded"(this);
            _palette.onColourRemoved.connect!"onPaletteColourRemoved"(this);

            foreach( c; _palette.colours ) {
                onPaletteColourAdded(c);
            }
        }
    }

private:

    void onPaletteChanged() {
        nameLabel.setText(_palette.name);
    }

    void onPaletteColourAdded(Colour c) {
        auto colourView = new PaletteListColourView(commandBus);
        colourListBox.packStart(colourView, false, false, 0);
        colourView.colour = c;
        listItems[c] = colourView;
        colourView.show();

        commandBus.send(new SelectColour(c));
    }

    void onPaletteColourRemoved(Colour c) {
        auto itemP = c in listItems;
        if( itemP !is null) {
            colourListBox.remove(*itemP);
            listItems.remove(c);
            colourListBox.queueDraw();
        }
    }

    void onAddColour(Button b) {
        commandBus.send(_palette.new AddColour(new Colour(0, 0, 0)));
    }
}

class PaletteListColourView : VBox {

mixin View;

private:

    Colour _colour;

    Bus commandBus;

    @GtkChild{
        HandleBox root;
        DrawingArea colourBox;
        Label nameLabel;
        Label hexLabel;
        Label tagsLabel;
    }

public:

    this(Bus commandBus) {
        super(true, 0);

        buildFromGlade();
        this.commandBus = commandBus;

        this.colourBox.addOnExpose(&onDrawColourBox);
        this.addOnButtonRelease(&onClicked);
    }

	void colour(Colour c) {
		if(_colour !is null) {
			_colour.onChange.disconnect!"onColourChange"(this);
		}
		_colour = c;
		if( c !is null) {
			_colour.onChange.connect!"onColourChange"(this);
            onColourChange();
		}
	}


private:

	void onColourChange() {
		colourBox.queueDraw();

        nameLabel.setText(_colour.name);

        hexLabel.setText(_colour.hex);
	}

	bool onDrawColourBox(GdkEventExpose* event, Widget self)
	{
		auto drawable = self.getWindow();
		auto context = new Context(drawable);
		context.setSourceRgb( _colour.dr, _colour.dg, _colour.db);
		context.paint();
		return true;
	}

    bool onClicked(GdkEventButton* event, Widget self)
    {
        commandBus.send(new SelectColour( _colour));
        return true;
    }



}
