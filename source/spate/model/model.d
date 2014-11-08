module spate.model.model;

import std.signals;

abstract class Model {
    mixin Signal!() onChange;
}
