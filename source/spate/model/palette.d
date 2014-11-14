module spate.model.palette;

import std.algorithm : find;
import std.container : Array;

import phobosx.signal;

debug import std.stdio;
import kdaf.bus;
import kdaf.model;

import spate.model.colour;

public class Palette : Model {

private:

    string _name;    
    Array!Colour _colours;

public:

    this(string name) {
        _name = name;
    }

    mixin(signal!(Colour)("onColourAdded"));
    mixin(signal!(Colour)("onColourRemoved"));

    string name() { return _name; }
    void name(string n) { _name = n; _onChange.emit(); }

    auto colours() { return _colours[]; }

    void addColour(Colour colour) {
        _colours ~= colour;
        _onColourAdded.emit(colour);
        _onChange.emit();
    }
    
    void removeColour(Colour colour) {
        _colours.linearRemove(_colours[].find(colour));
        _onColourRemoved.emit(colour);
        _onChange.emit();
    }

private:


//Commands
public:

    class ChangeName : ICommand {
        mixin Command;

        public:
        string from, to;

        this(string from, string to) {
            this.from = from;
            this.to = to;
        }

        ICommand inverse() {
            return new ChangeName(to, from);
        }
    }

    class AddColour : ICommand {
        mixin Command;

        public:
        Colour colour;

        this(Colour colour) {
            this.colour = colour;
        }

        ICommand inverse() {
            return new RemoveColour(colour);
        }
    }

    class RemoveColour : ICommand {
        mixin Command;

        public:
        Colour colour;

        this(Colour colour) {
            this.colour = colour;
        }

        ICommand inverse() {
            return new AddColour(colour);
        }
    }

}
