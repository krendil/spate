module spate.model.colour;

import kdaf.bus;
import spate.types;
import spate.model.model;

public enum ColourSpace {
    sRGB,
    HSV
}

public final class Colour : Model {
    
private:


    ubyte[3] _rgb;

    string _name;

    Set!string _tags = new Set!string();

public:

    this(ubyte r, ubyte g, ubyte b) {
        this._rgb = [r, g, b];
    }

    const(ubyte[]) rgb() const { return _rgb[]; }

    ubyte opIndex(size_t idx) { return _rgb[idx]; }
    void opIndexAssign(ubyte value, size_t idx) { _rgb[idx] = value; onChange.emit(); }

    ubyte r() const { return _rgb[0]; }
    ubyte g() const { return _rgb[1]; }
    ubyte b() const { return _rgb[2]; }

    double dr() const { return _rgb[0] / 255.0; }
    double dg() const { return _rgb[1] / 255.0; }
    double db() const { return _rgb[2] / 255.0; }

    string name () { return _name; }
    void name(string value) { _name = value; onChange.emit(); }

    auto tags() { return _tags[]; }

    void addTag(string tag) {
        if( ! (tag in _tags)) {
            _tags.insert(tag);
            onChange.emit();
        }
    }

    void removeTag(string tag) {
        if(_tags.removeKey(tag)) {
            onChange.emit();
        }
    }


    //Commands

public static:
    class ChangeColour : ICommand {
        mixin Command;

        public:
        Colour colour;
        size_t component;
        ubyte from;
        ubyte to;

        this(Colour colour, size_t component, ubyte from, ubyte to) {
            this.colour = colour;
            this.component = component;
            this.from = from;
            this.to = to;
        }

        override ICommand inverse() {
            return new ChangeColour(colour, component, to, from);
        }
    }

    class AddTag : ICommand {
        mixin Command;

        public:
        Colour colour;
        string tag;

        this(Colour colour, string tag) {
            this.colour = colour;
            this.tag = tag;
        }

        override ICommand inverse() {
            return new RemoveTag(colour, tag);
        }
    }

    class RemoveTag : ICommand {
        mixin Command;

        public:
        Colour colour;
        string tag;

        this(Colour colour, string tag) {
            this.colour = colour;
            this.tag = tag;
        }

        override ICommand inverse() {
            return new AddTag(colour, tag);
        }
    }

    class ChangeName : ICommand {
        mixin Command;

        public:
        Colour colour;
        string from;
        string to;

        this(Colour colour, string from, string to) {
            this.colour = colour;
            this.from = from;
            this.to = to;
        }

        override ICommand inverse() {
            return new ChangeName(colour, to, from);
        }
    }

}
