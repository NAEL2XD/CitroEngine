package citro.object;

import cxx.num.UInt32;

@:headerCode('
#include <3ds.h>
#include <citro2d.h>
#include <citro3d.h>
')

@:cppFileCode('
static C2D_Font fnt = NULL;
static C2D_TextBuf g_staticBuf = NULL;

static u32 applyAlpha(u32 color, float alpha) {
    u8 a = static_cast<u8>(((color >> 24) & 0xFF) * alpha);
    u8 r = (color >> 16) & 0xFF;
    u8 g = (color >> 8) & 0xFF;
    u8 b = color & 0xFF;
    
    return (a << 24) | (b << 16) | (g << 8) | r;
}')

enum abstract Align(Int) {
    /**
     * Sets the text's alignment to the left screen.
     */
    var LEFT;

    /**
     * Sets the text's alignment to the center screen.
     */
    var CENTER;

    /**
     * Sets the text's alignment to the right screen.
     */
    var RIGHT;
}

enum abstract BorderStyle(Int) {
    /**
     * Do not display any border to it.
     */
    var NONE;

    /**
     * Displays border in all direction even diagonal.
     */
    var OUTLINE;

    /**
     * Displays a shadowy text (`y++` then `x--`);
     */
    var SHADOW;
}

@:nativeGen
class CitroText extends CitroObject {
    /**
     * The current text being displayed in screen.
     */
    public var text:String = "";

    /**
     * Current alignment usage.
     */
    public var alignment:Align = LEFT;

    /**
     * Current color for this border
     */
    public var borderColor:UInt32 = 0xFF000000;

    /**
     * Current size of this border.
     */
    public var borderSize:Float = 1;

    /**
     * Style to use as.
     * @see borderStyle enum
     */
    public var borderStyle:BorderStyle = NONE;

    /**
     * Creates a new object text that can display whetever text you wanna use, or have fun with it.
     * @param xPos The X position to use.
     * @param yPos The Y position to use.
     * @param Text The current text string to use.
     */
    public function new(xPos:Float = 0, yPos:Float = 0, Text:String = "") {
        super();

        x = xPos;
        y = yPos;
        text = Text;

        untyped __cpp__('
            Mtx_Identity(&this->matrix);
            this->defaultFont = NULL;

            if (g_staticBuf == NULL) {
                fnt = C2D_FontLoadSystem(CFG_REGION_USA);
                g_staticBuf = C2D_TextBufNew(4096);
            }
        ');
    }

    override function update(delta:Int) {
        super.update(delta);

        if (isDestroyed || !visible || alpha < 0) {
            return;
        }

        untyped __cpp__('
            C2D_TextBufClear(g_staticBuf);
        
            C2D_Text c2dText;
            C2D_TextFontParse(&c2dText, this->defaultFont ? this->defaultFont : fnt, g_staticBuf, this->text.c_str());
            C2D_TextOptimize(&c2dText);
        
            float width, height;
            C2D_TextGetDimensions(&c2dText, this->scale->x, this->scale->y, &width, &height);
            this->width = width;
            this->height = height;

            float newX = this->x, newY = this->y, newSW = this->scale->x, newSH = this->scale->x;
            if (this->camera != nullptr || this->camera != NULL) {
                newSW *= this->camera->_curZm;
                newSH *= this->camera->_curZm;
                newX = (newX * newSW) + this->camera->_xPtr;
                newY = (newY * newSH) + this->camera->_yPtr;
            }

            switch (this->alignment) {
                case 0: break;
                case 1: newX += this->bottom ? (320 - this->width) / 2 : (400 - this->width) / 2; break;
                case 2: newX += this->bottom ? 320 - this->width : 400 - this->width; break;
            }

            C2D_ViewSave(&this->matrix);
            C2D_ViewTranslate(newX, newY);
            C2D_ViewTranslate(this->width * newSW / 2, this->height * newSH / 2);
            C2D_ViewRotate(this->angle * M_PI / 180);
            C2D_ViewScale(newSW, newSH);
            C2D_ViewTranslate(-this->width / 2, -this->height / 2);

            if (this->borderStyle != 0 && this->borderSize >= 0) {
                u32 bCol = applyAlpha(this->borderColor, alpha);
                switch(this->borderStyle) {
                    case 0: break;
                    case 1: {
                        int offsets[8][2] = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}};
                        for (int i = 0; i < 8; i++) {
                            C2D_DrawText(&c2dText, C2D_WithColor, (offsets[i][0] * this->borderSize), (offsets[i][1] * this->borderSize), 0, 1, 1, bCol);
                        }
                        break;
                    }
                    case 2: {
                        for (int i = 1; i < static_cast<int>(this->borderSize + 1); i++) {
                            C2D_DrawText(&c2dText, C2D_WithColor, -i, i, .5, 1, 1, bCol);
                        }
                        break;
                    }
                }
            }

            C2D_DrawText(&c2dText, C2D_WithColor, 0, 0, 0, 1, 1, applyAlpha(this->color, this->alpha));
            C2D_ViewRestore(&this->matrix)
        ');
    }

    /**
     * Loads a font path provided.
     * @param path The file path to use, not needed to include `romfs:/`, also make sure it's converted to BCFNT.
     */
    public function loadFont(path:String):Bool {
        path = 'romfs:/$path';
        return untyped __cpp__('(this->defaultFont = C2D_FontLoad(path.c_str())) != NULL');
    }

    override function destroy() {
        super.destroy();

        untyped __cpp__('
            if (this->defaultFont) {
                C2D_FontFree(this->defaultFont);
                this->defaultFont = NULL;
            }
        ');
    }
}