module spate.model.colour;

debug import std.stdio;

import std.algorithm;
import std.conv;
import std.format;
import std.math;
import std.regex;
import std.string;

import kdaf.bus;
import spate.types;
import spate.model.model;

Hsv rgb2hsv(const ubyte[3] rgb) {

    Hsv hsv;
    double[3] rgb_f = void;
    rgb_f[0] = rgb[0] / 255.0;
    rgb_f[1] = rgb[1] / 255.0;
    rgb_f[2] = rgb[2] / 255.0;

    auto max = max(rgb_f[0], rgb_f[1], rgb_f[2]);

    if(max == 0f) {
        return Hsv(0, 0, 0);
    }

    auto min = min(rgb_f[0], rgb_f[1], rgb_f[2]);
    auto delta = max - min;

    hsv.Sat = (max == 0) ? 0 : delta/max;
    hsv.Val = max;

    if( delta == 0 ) {
        hsv.Hue = 0;
    } else if(max == rgb_f[0] ) {
        hsv.Hue = 60 * ( (rgb_f[1] - rgb_f[2]) / delta);
        if(hsv.Hue < 0) hsv.Hue += 360;
    } else if(max == rgb_f[1] ) {
        hsv.Hue = 60 * ( (rgb_f[2] - rgb_f[0]) / delta + 2);
    } else {
        hsv.Hue = 60 * ( (rgb_f[0] - rgb_f[1]) / delta + 4);
    }

    return hsv;
}

ubyte[3] hsv2rgb(const ref Hsv hsv) {
    ubyte[3] rgb = void;

    auto h_ = hsv.Hue / 60.0;
    uint hexant = cast(uint) h_;
    h_ -= hexant;

    double full = hsv.Val * 255.0;
    auto wax = full * (1.0 - (hsv.Sat * (1.0 - h_)));
    auto wane = full * (1.0 - (hsv.Sat * h_));
    auto empty = full * (1.0 - hsv.Sat);

    //debug writefln("%s %s %s %s", full, wax, wane, empty);

    switch(hexant) {
        case 6:
        case 0:
            rgb[0] = cast(ubyte) rint(full);
            rgb[1] = cast(ubyte) rint(wax);
            rgb[2] = cast(ubyte) rint(empty);
            break;
        case 1:
            rgb[0] = cast(ubyte) rint(wane);
            rgb[1] = cast(ubyte) rint(full);
            rgb[2] = cast(ubyte) rint(empty);
            break;
        case 2:
            rgb[0] = cast(ubyte) rint(empty);
            rgb[1] = cast(ubyte) rint(full);
            rgb[2] = cast(ubyte) rint(wax);
            break;
        case 3:
            rgb[0] = cast(ubyte) rint(empty);
            rgb[1] = cast(ubyte) rint(wane);
            rgb[2] = cast(ubyte) rint(full);
            break;
        case 4:
            rgb[0] = cast(ubyte) rint(wax);
            rgb[1] = cast(ubyte) rint(empty);
            rgb[2] = cast(ubyte) rint(full);
            break;
        case 5:
        default:
            rgb[0] = cast(ubyte) rint(full);
            rgb[1] = cast(ubyte) rint(empty);
            rgb[2] = cast(ubyte) rint(wane);
            break;
    }
    return rgb;
}

unittest {

    ubyte[3] red = [255, 0, 0];
    Hsv redHsv = rgb2hsv(red);

    assert(redHsv == Hsv(0, 1, 1), "HSV: Red conversion failed: "~ redHsv.to!string);

    red = hsv2rgb(redHsv);
    assert( red == [255, 0, 0], "HSV: Red roundtrip failed: "~ red.to!string);

    ubyte[3] black = [0, 0, 0];
    Hsv blackHsv = rgb2hsv(black);
    assert(blackHsv == Hsv(0, 0, 0), "HSV: Black conversion failed: "~ blackHsv.to!string);

    black = hsv2rgb(blackHsv);
    assert( red == [255, 0, 0], "HSV: Black roundtrip failed: "~ black.to!string);

    ubyte[3] green = [127, 255, 127];
    Hsv greenHsv = rgb2hsv(green);
    assert(greenHsv == Hsv(120, 0.5, 1), "HSV: green conversion failed: "~ greenHsv.to!string);

    green = hsv2rgb(greenHsv);
    assert( green == [127, 255, 127], "HSV: green roundtrip failed: "~ green.to!string);

    ubyte[3] green2 = [52, 89, 37];
    Hsv green2Hsv = rgb2hsv(green2);
    assert(green2Hsv == Hsv(102.69, .584, .349), "HSV: green conversion failed: "~ green2Hsv.to!string);

    green = hsv2rgb(green2Hsv);
    assert( green2 == [52, 89, 37], "HSV: green roundtrip failed: "~ green2.to!string);

    ubyte[3] grey = [13, 13, 13];
    Hsv greyHsv = rgb2hsv(grey);
    assert(greyHsv == Hsv(0, 0, 0.051), "HSV: grey conversion failed: "~ greyHsv.to!string);

    grey = hsv2rgb(greyHsv);
    assert( grey == [13, 13, 13], "HSV: grey roundtrip failed: "~ grey.to!string);

    ubyte[3] red2 = [52, 89, 37];
    Hsv red2Hsv = rgb2hsv(red2);
    assert(red2Hsv == Hsv(102.69, .584, .349), "HSV: red conversion failed: "~ red2Hsv.to!string);

    red2 = hsv2rgb(red2Hsv);
    assert( red2 == [52, 89, 37], "HSV: red roundtrip failed: "~ red2.to!string);

    ubyte[3] black2 = [3, 0, 1];
    Hsv black2Hsv = rgb2hsv(black2);
    assert(black2Hsv == Hsv(340, 1, 0.01), "HSV: black2 conversion failed: "~ black2Hsv.to!string);

    black2 = hsv2rgb(black2Hsv);
    assert( black2 == [3, 0, 1], "HSV: black2 roundtrip failed: "~ black2.to!string);

    version(HsvTest) {
        import std.algorithm;
        import std.range;
        import std.typecons;
        import std.stdio;
        import std.math;
        import std.parallelism;

        auto meanMax = 
            reduce!( (seed, value) => ( tuple(++seed[0], seed[1] + value) ),
                    max )(
                        tuple(tuple(0, 0), 0), //Meanseed, Maxseed
                        taskPool.map!(
                            (Tuple!(ubyte,ubyte,ubyte) rgbt) {
                            ubyte[3] rgb = [rgbt[0], rgbt[1], rgbt[2]];
                            Hsv hsv;
                            hsv = rgb2hsv(rgb);
                            rgb = hsv2rgb(hsv);
                            auto err = (abs(rgbt[0]-rgb[0]) + abs(rgbt[1]-rgb[1]) + abs(rgbt[2]-rgb[2]));
                            if(err >= 20) {
                            stdout.lockingTextWriter.formattedWrite("%s -> %s\n", rgbt, rgb);
                            }
                            return err;
                            })
                        (cartesianProduct( iota!ubyte(255u), iota!ubyte(255u), iota!ubyte(255u) ))
                        );

        writefln("Mean error: %s", meanMax[0][1] / cast(double) meanMax[0][0]);
        writefln("Max error: %s", meanMax[1]);
    }
}

private struct Hsv {
    double Hue;
    double Sat;
    double Val;

    public bool opEquals()(auto ref Hsv other) const {
        import std.math : abs;
        enum eps = 0.005;
        return abs(Hue - other.Hue) < eps
            && abs(Sat - other.Sat) < eps
            && abs(Val - other.Val) < eps;
    }
}

public final class Colour : Model {

private:

    ubyte[3] _rgb;
    Hsv _hsv;

    string _name;

    Set!string _tags = new Set!string();

public:

    this(ubyte r, ubyte g, ubyte b) {
        this._rgb = [r, g, b];
        this._hsv = rgb2hsv(_rgb);
    }

    const(ubyte[]) rgb() const { return _rgb[]; }

    ubyte opIndex(size_t idx) { return _rgb[idx]; }
    void opIndexAssign(ubyte value, size_t idx) {
        if(_rgb[idx] != value) {
            _rgb[idx] = value;
            _hsv = rgb2hsv(_rgb);
            onChange.emit();
        }
    }

    ubyte r() const { return _rgb[0]; }
    ubyte g() const { return _rgb[1]; }
    ubyte b() const { return _rgb[2]; }

    double dr() const { return _rgb[0] / 255.0; }
    double dg() const { return _rgb[1] / 255.0; }
    double db() const { return _rgb[2] / 255.0; }

    string hex() const { return format("#%02x%02x%02x", r, g, b); }

    auto h() const { return _hsv.Hue; }
    auto s() const { return _hsv.Sat * 100.0; }
    auto v() const { return _hsv.Val * 100.0; }

    void h(double h) {
        _hsv.Hue = h;
        _rgb = hsv2rgb(_hsv);
        onChange.emit();
    }
    void s(double s) {
        _hsv.Sat = s / 100.0;
        _rgb = hsv2rgb(_hsv);
        onChange.emit();
    }
    void v(double v) {
        _hsv.Val = v / 100.0;
        _rgb = hsv2rgb(_hsv);
        onChange.emit();
    }

    void hex(string h) {
        static spec = singleSpec("%x");
        static enum regex = ctRegex!"^#?[0-9a-fA-F]{6}$";
        uint newRgb;

        if(h.matchFirst(regex).empty)
            return;

        if(h[0] == '#')
            h = h[1..$];

        if(h.length != 6)
            return;

        auto cleanH = h.toLower();

        newRgb = cleanH.unformatValue!uint(spec);

        foreach( i; 0..3) {
            _rgb[2-i] = newRgb & 0xFF;
            newRgb >>= 8;
        }

        _hsv = rgb2hsv(_rgb);

        onChange.emit();
    }

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

public:
    class ChangeColour : ICommand {
        mixin Command;

        public:
        ubyte component;
        ubyte from;
        ubyte to;

        this(ubyte component, ubyte from, ubyte to) {
            this.component = component;
            this.from = from;
            this.to = to;
        }

        override ICommand inverse() {
            return new ChangeColour(component, to, from);
        }
    }

    class ChangeHsv : ICommand {
        mixin Command;

        public:
        char component;
        double from;
        double to;

        this(char component, double from, double to) {
            this.component = component;
            this.from = from;
            this.to = to;
        }

        override ICommand inverse() {
            return new ChangeHsv(component, to, from);
        }
    }

    class AddTag : ICommand {
        mixin Command;

        public:
        string tag;

        this(string tag) {
            this.tag = tag;
        }

        override ICommand inverse() {
            return new RemoveTag(tag);
        }
    }

    class RemoveTag : ICommand {
        mixin Command;

        public:
        string tag;

        this(string tag) {
            this.tag = tag;
        }

        override ICommand inverse() {
            return new AddTag(tag);
        }
    }

    class ChangeName : ICommand {
        mixin Command;

        public:
        string from;
        string to;

        this(string from, string to) {
            this.from = from;
            this.to = to;
        }

        override ICommand inverse() {
            return new ChangeName(to, from);
        }
    }

    class ChangeHex : ICommand {
        mixin Command;

        public:
        string from;
        string to;

        this(string from, string to) {
            this.from = from;
            this.to = to;
        }

        override ICommand inverse() {
            return new ChangeHex(to, from);
        }
    }
}

class SelectColour : ICommand {
    mixin Command;

    public:
    Colour from;
    Colour to;

    this(Colour from, Colour to) {
        this.from = from;
        this.to = to;
    }

    ICommand inverse() {
        return new SelectColour(to, from);
    }
}

unittest {

    Colour red = new Colour(255, 0, 0);

    assert(red.hex == "#ff0000", "Colour: Hex output wrong: "~red.hex);

    red.hex = "#AA0000";

    assert(red.hex == "#aa0000", "Colour: Hex input wrong: "~red.hex);
    assert(red.r == 170u, "Colour: Hex input wrong: "~red.r.to!string);
    assert(red.h == 0.0, "Colour: Hue calc failed: "~red.h.to!string);

    red.hex = "0000bb";

    assert(red.hex == "#0000bb", "Colour: Hashless hex input wrong: "~red.hex);
    assert(red.r == 0, "Colour: Hashless hex input wrong: "~red.r.to!string);
    assert(red.b == 187, "Colour: Hashless hex input wrong: "~red.b.to!string);

    red.hex = "ff000000bbb000b0b0bbb0";
    assert(red.hex == "#0000bb", "Colour: Didn't discard invalid hex: "~red.hex);

    red.h = 120.0;
    assert(red.hex == "#00bb00", "Colour: Hue assign failed: "~red.hex);
}
