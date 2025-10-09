import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroInit;

/**
 * This is where your code will be ran when game is compiled.
 */
function main() {
	GFX.initDefault();
	RomFS.init();

	/**
	 * This is also where your game state will be located.
	 */
	CitroInit.init(new GameState());

	RomFS.exit();
	GFX.exit();
}