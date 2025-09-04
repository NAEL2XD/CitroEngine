package citro;

import haxe3ds.services.HID;
import haxe3ds.services.APT;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import citro.state.CitroSubState;
import citro.object.CitroText;
import haxe3ds.OS;
import cxx.num.UInt64;
import citro.state.CitroState;

@:headerCode("
#include <citro2d.h>
#include <citro3d.h>
#include <SDL.h>
#include <SDL_mixer.h>

extern C3D_RenderTarget* topScreen;
extern C3D_RenderTarget* bottomScreen;
")

@:cppFileCode('
#include <3ds.h>
#include <stdlib.h>

C3D_RenderTarget* topScreen = nullptr;
C3D_RenderTarget* bottomScreen = nullptr;
')

/**
 * Literally everything to set up.
 */
class CitroInit {
    public static var callCreate:Bool = true;
    public static var shouldQuit:Bool = false;
    public static var debugTexts:Array<CitroText> = [];
    public static var curState:CitroState;
    public static var subState:CitroSubState;
    public static var destroySS:Bool = false;

    static function renderSprite(state:CitroState, delta:Int) {
        var i:Int = 0;
        for (member in state.members) {
            if (member.isDestroyed) {
                state.members.splice(i, 1);
                continue;
            }

            untyped __cpp__("C2D_SceneBegin(member->bottom ? bottomScreen : topScreen)");
            member.update(delta);
            i++;
        }
    }

    /**
     * Initializes CitroEngine and brings back your games into the 3DS!
     * @param state Current state to use as.
     */
    public static function init(state:CitroState) {
        callCreate = true;
        curState = state;
        subState = null;

        untyped __cpp__('
            C2D_Init(C2D_DEFAULT_MAX_OBJECTS);
            C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
            C2D_Prepare();

            topScreen = C2D_CreateScreenTarget(GFX_TOP,    GFX_LEFT);
            bottomScreen = C2D_CreateScreenTarget(GFX_BOTTOM, GFX_LEFT);

            srand(time(NULL))
        ');
        
        var deltaTime:Int = 0;
        while (APT.mainLoop() && !shouldQuit) {
            final old:UInt64 = OS.getTime();

            if (destroySS) {
                subState = null;
                destroySS = false;
            }

            final s:Bool = untyped __cpp__('citro::CitroInit::subState == nullptr || citro::CitroInit::subState == NULL');
            if (callCreate) {
                (s ? curState : subState).create();
                callCreate = false;
            }
        
            HID.scanInput();
            untyped __cpp__('
                C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
                C2D_TargetClear(topScreen, 0xFF000000);
                C2D_TargetClear(bottomScreen, 0xFF000000)
            ');

            CitroTween.update(deltaTime);
            CitroTimer.update(deltaTime);
            
            renderSprite(curState, deltaTime);
            if (!s) renderSprite(subState, deltaTime);
            (s ? curState : subState).update(deltaTime);

            var t:Int = debugTexts.length-1;
            while (t != -1) {
                while (t >= 21) {
                    debugTexts.splice(0, 1);
                    t--;
                }

                var dText:CitroText = debugTexts[t];
                dText.y = 4 + (11 * t);
                dText.update(deltaTime);

                t--;
            }

            untyped __cpp__('C3D_FrameEnd(0)');
            deltaTime = OS.getTime() - old;
        }

        untyped __cpp__('
	        C3D_Fini();
	        C2D_Fini();
	        Mix_CloseAudio();
	        Mix_Quit();
	        SDL_Quit()
	    ');
    }
}