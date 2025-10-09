package citro.object;

import citro.object.CitroSprite;
import haxe3ds.stdutil.FSUtil;

using StringTools;

private typedef CitroAnimateHeader = {
    var frameX:Float;
    var frameY:Float;
    var sprite:CitroSprite;
}

/**
 * A class for animation purpose.
 */
class CitroAnimate extends CitroObject {
    var timeLeft:Int = 0;
    var sprites:Map<String, CitroAnimateHeader> = [];

    /**
     * The fps for this animation to use.
     */
    public var fps:Float = 24;

    /**
     * The current frame for this animation playing.
     */
    public var frame:Int = 0;

    /**
     * The current playing animation name that's gonna be used.
     */
    public var animPlay:String = "";

    /**
     * Constructs this sprite.
     * @param craFile Path to the `.cea` (Citro Engine Animate) file to parse, `romfs:/` included.
     */
    public function new(ceaFile:String) {
        super();

        var file = FSUtil.readFile('romfs:/${ceaFile}');
        ceaFile = ceaFile.substr(0, ceaFile.lastIndexOf("/"));
        if (file != "") {
            var i:Int = 0;
            var old:Array<String> = [];
            for (line in file.split("\n")) {
                var row = line.split("?");
                row[3] = row[3].trim();

                if (!old.join(" ").contains(row[3])) {
                    old.push(row[3]);
                    i = -1;
                }
                i++;

                var sprite = new CitroSprite();
                sprite.loadGraphic('$ceaFile/${row[0]}');
                sprites.set('${row[3]}-$i', {
                    frameX: Std.parseFloat(row[1]),
                    frameY: Std.parseFloat(row[2]),
                    sprite: sprite
                });
            }
        }
    }

    /**
     * Plays a new animation that's found in the sprite's map.
     * @param animation Animation name to play.
     */
    public function play(animation:String):Bool {
        var old = frame;
        frame = 0;

        for (key in sprites.keys()) {
            if (key == '${animation}-0') {
                animPlay = animation;
                return true;
            }
        }

        frame = old;
        return false;
    }

    override function update(delta:Int):Bool {
        timeLeft -= delta;
        if (timeLeft < 1) {
            timeLeft = Std.int(1000 / fps);
            frame++;
            if (!sprites.exists('${animPlay}-$frame')) {
                frame--;
            }
        }

        if (sprites.exists('${animPlay}-$frame')) {
            var header = sprites.get('${animPlay}-$frame');
            header.sprite.x = x - (header.frameX * scale.x);
            header.sprite.y = y - (header.frameY * scale.y);
            header.sprite.scale.x = scale.x;
            header.sprite.scale.y = scale.y;
            return header.sprite.update(delta);
        }

        return false;
    }

    override function destroy() {
        for (key in sprites) {
            key.sprite.destroy();
        }

        super.destroy();
    }
}