module spate.controller.colourcontroller;

import kdaf.bus;
import spate.model.colour;

class ColourController {

private:

    Bus commandBus;

public:

    this(Bus commandBus) {
        this.commandBus = commandBus;

        commandBus.subscribe(&onChangeColour);
        commandBus.subscribe(&onAddTag);
        commandBus.subscribe(&onRemoveTag);
        commandBus.subscribe(&onChangeName);
    }

private:

    void onChangeColour(Colour.ChangeColour cmd) {
        cmd.colour[cmd.component] = cmd.to;
    }

    void onAddTag(Colour.AddTag cmd) {
        cmd.colour.addTag(cmd.tag);
    }

    void onRemoveTag(Colour.RemoveTag cmd) {
        cmd.colour.removeTag(cmd.tag);
    }

    void onChangeName(Colour.ChangeName cmd) {
        cmd.colour.name = cmd.to;
    }


}
