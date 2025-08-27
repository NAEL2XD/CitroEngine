import haxe3ds.RomFS;
import haxe3ds.GFX;
import backend.Saving;
import citro.CitroInit;

function main() {
	GFX.initDefault();
	RomFS.init();

	untyped __cpp__('
		SDL_Init(SDL_INIT_AUDIO);
		Mix_Init(MIX_INIT_OGG);
		Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024);
		Mix_AllocateChannels(1024);
		Mix_Volume(-1, MIX_MAX_VOLUME)
	');

	Saving.load();
	CitroInit.init(new states.GameState());
	Saving.saveTheSave();

	untyped __cpp__('
	    C3D_Fini();
	    C2D_Fini();
	    Mix_CloseAudio();
	    Mix_Quit();
	    SDL_Quit()
	');

	RomFS.exit();
	GFX.exit();
}