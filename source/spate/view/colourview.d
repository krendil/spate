module spate.view.colourview;

import std.typecons;
debug import std.stdio;

import cairo.Context;

import gtk.Builder;
import gtk.DrawingArea;
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
	}

public:

	mixin View;

	this(Bus commandBus) {
		super(true, 0);
		this.commandBus = commandBus;
		buildFromGlade();

		colourBox.addOnExpose(&onDrawColourBox);
		redSpin.addOnValueChanged(&onSpinValueChanged!0);
		greenSpin.addOnValueChanged(&onSpinValueChanged!1);
		blueSpin.addOnValueChanged(&onSpinValueChanged!2);
	}

	
	void colour(Colour c) {
		if(_colour !is null) {
			_colour.onChange.disconnect(&onColourChange);
		}
		_colour = c;
		if( c !is null) {
			_colour.onChange.connect(&onColourChange);
		}
	}

private:

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
	}

	void onSpinValueChanged(size_t field)(SpinButton self) {
		commandBus.send(new Colour.ChangeColour(_colour, field, _colour[field], cast(ubyte) self.getValueAsInt()));
	}
}
