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
        commandBus.subscribe(&onChangeHsv);
    }

private:

    void onChangeColour(Colour.ChangeColour cmd) {
        cmd.outer[cmd.component] = cmd.to;
    }

    void onAddTag(Colour.AddTag cmd) {
        cmd.outer.addTag(cmd.tag);
    }

    void onRemoveTag(Colour.RemoveTag cmd) {
        cmd.outer.removeTag(cmd.tag);
    }

    void onChangeName(Colour.ChangeName cmd) {
        cmd.outer.name = cmd.to;
    }

    void onChangeHsv(Colour.ChangeHsv cmd) {
        switch(cmd.component) {
            case 'h':
                cmd.outer.h = cmd.to;
                break;
            case 's':
                cmd.outer.s = cmd.to;
                break;
            case 'v':
                cmd.outer.v = cmd.to;
                break;
            default:
                break;
        }
    }


}
