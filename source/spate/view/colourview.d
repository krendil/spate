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
		SpinButton redSpin;
		SpinButton greenSpin;
		SpinButton blueSpin;
        Entry hexEntry;
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

		colourBox.addOnExpose(&onDrawColourBox);
		redSpin.addOnValueChanged(&onRgbValueChanged!0);
		greenSpin.addOnValueChanged(&onRgbValueChanged!1);
		blueSpin.addOnValueChanged(&onRgbValueChanged!2);
        hexEntry.addOnChanged(&onHexChanged);

        hueSpin.addOnValueChanged(&onHsvValueChanged!'h');
        satSpin.addOnValueChanged(&onHsvValueChanged!'s');
        valSpin.addOnValueChanged(&onHsvValueChanged!'v');

        commandBus.subscribe(&onColourSelected);
	}

	
	void colour(Colour c) {
		if(_colour !is null) {
			_colour.onChange.disconnect(&onColourChange);
		}
		_colour = c;
		if( c !is null) {
			_colour.onChange.connect(&onColourChange);
            onColourChange();
		}
	}

private:

    void onColourSelected(SelectColour cmd) {
        this.colour = cmd.to;
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
		redSpin.setValue(_colour.r);
		greenSpin.setValue(_colour.g);
		blueSpin.setValue(_colour.b);
        hexEntry.setText(_colour.hex);

        hueSpin.setValue(_colour.h);
        satSpin.setValue(_colour.s);
        valSpin.setValue(_colour.v);
	}

	void onRgbValueChanged(size_t field)(SpinButton self) {
		commandBus.send(_colour.new ChangeColour(field, _colour[field], cast(ubyte) self.getValueAsInt()));
	}

	void onHsvValueChanged(char field)(SpinButton self) {
		commandBus.send(_colour.new ChangeHsv(field, mixin("_colour."~field), self.getValue()));
	}

    void onHexChanged(EditableIF e) {
        commandBus.send(_colour.new ChangeHex(_colour.hex, hexEntry.getText()));
    }
}
