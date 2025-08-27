package citro.state;

import citro.object.CitroObject;
import citro.object.CitroSprite;
import cxx.num.UInt32;

class CitroSubState extends CitroState {
    /**
     * Handler for opening new substates.
     * @param color Color to use as it's substate (or pause), leave empty for invisible.
     */
    public function new(color:UInt32 = 0x0) {
        super();

        for (i in 0...2) {
            var col:CitroSprite = new CitroSprite();
            col.makeGraphic(400, 240, color);
            col.bottom = i == 1;
            add(col);
        }
    }

    override function destroy() {
        super.destroy();
    }

    /**
     * Forcefully closes this substate and goes back to the current state.
     */
    public function close() {
        destroy();
        CitroInit.destroySS = true;
    }

    override function openSubstate(substate:CitroSubState) {
        return;
        super.openSubstate(substate);
    }

    override function add(member:CitroObject) {
        super.add(member);
    }

    override function create() {
        super.create();
    }

    override function insert(index:Int, member:CitroObject) {
        super.insert(index, member);
    }

    override function update(delta:Int) {
        super.update(delta);
    }
}