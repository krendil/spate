module spate.controller.palettecontroller;


debug import std.stdio;
import kdaf.bus;
import spate.model.colour;
import spate.model.palette;

class PaletteController {

private:

    Bus commandBus;

public:

    this(Bus commandBus) {
        this.commandBus = commandBus;

        commandBus.subscribe(&onChangeName);
        commandBus.subscribe(&onAddColour);
        commandBus.subscribe(&onRemoveColour);
    }

private:

    void onChangeName(Palette.ChangeName cmd) {
        cmd.outer.name = cmd.to;
    }

    void onAddColour(Palette.AddColour cmd) {
        cmd.outer.addColour(cmd.colour);
    }

    void onRemoveColour(Palette.RemoveColour cmd) {
        cmd.outer.removeColour(cmd.colour);
    }

}
