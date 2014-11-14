module spate.view.colourview;

import std.typecons;
debug import std.stdio;

import cairo.Context;

import gtk.Builder;
import gtk.DrawingArea;
import gtk.EditableIF;
import gtk.Entry;
import gtk.SpinButton;
import gtk.VBox;
import gtk.Widget;

import kdaf.bus;
import kdaf.view;
import spate.model.colour;

public class ColourView : VBox {

private:

	Rebindable!(Colour) _colour;
	Bus commandBus;

	@GtkChild {
		DrawingArea colourBox;

        Entry nameEntry;

        Entry hexEntry;
		SpinButton redSpin;
		SpinButton greenSpin;
		SpinButton blueSpin;

		SpinButton hueSpin;
		SpinButton satSpin;
		SpinButton valSpin;
	}

public:

	mixin View;

	this(Bus commandBus) {
		super(true, 0);
		this.commandBus = commandBus;
		buildFromGlade();

        nameEntry.addOnChanged(&onNameChanged);

		colourBox.addOnExpose(&onDrawColourBox);

        hexEntry.addOnChanged(&onHexChanged);
		redSpin.addOnValueChanged(&onRgbValueChanged!0);
		greenSpin.addOnValueChanged(&onRgbValueChanged!1);
		blueSpin.addOnValueChanged(&onRgbValueChanged!2);

        hueSpin.addOnValueChanged(&onHsvValueChanged!'h');
        satSpin.addOnValueChanged(&onHsvValueChanged!'s');
        valSpin.addOnValueChanged(&onHsvValueChanged!'v');

        commandBus.subscribe(&onColourSelected);
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

    void onColourSelected(SelectColour cmd) {
        this.colour = cmd.colour;
    }

	bool onDrawColourBox(GdkEventExpose* event, Widget self)
	{
		auto drawable = self.getWindow();
		auto context = new Context(drawable);
		context.setSourceRgb( _colour.dr, _colour.dg, _colour.db);
		context.paint();
		return true;
	}

	void onColourChange() {
		colourBox.queueDraw();

        if(_colour.name.length == 0) {
            nameEntry.setText("");
        } else {
            nameEntry.setText(_colour.name);
        }

        hexEntry.setText(_colour.hex);

		redSpin.setValue(_colour.r);
		greenSpin.setValue(_colour.g);
		blueSpin.setValue(_colour.b);

        hueSpin.setValue(_colour.h);
        satSpin.setValue(_colour.s);
        valSpin.setValue(_colour.v);
	}

    void onNameChanged(EditableIF e) {
        commandBus.send(_colour.new ChangeName(_colour.name, nameEntry.getText()));
    }

    void onHexChanged(EditableIF e) {
        commandBus.send(_colour.new ChangeHex(_colour.hex, hexEntry.getText()));
    }

	void onRgbValueChanged(size_t field)(SpinButton self) {
		commandBus.send(_colour.new ChangeColour(field, _colour[field], cast(ubyte) self.getValueAsInt()));
	}

	void onHsvValueChanged(char field)(SpinButton self) {
		commandBus.send(_colour.new ChangeHsv(field, mixin("_colour."~field), self.getValue()));
	}

}
