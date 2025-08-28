package citro.object;

import cxx.num.UInt32;

@:headerCode('
#include <citro2d.h>
#include <citro3d.h>

typedef struct {
    C2D_SpriteSheet ss;
    C2D_Image image;
    C3D_Mtx matrix;
    C2D_ImageTint tint;
} C2D_Data;

#define colorConvert(e) (((e) & 0xFF00FF00) | (((e) >> 16) & 0xFF) | (((e) & 0xFF) << 16))
')

@:headerClassCode('
    C2D_Data data;
')

@:cppFileCode('#include "citro_CitroInit.h"')
class CitroSprite extends CitroObject {
    /**
     * Creates a new Citro Sprite, which can load images, graphic and even more!
     * @param xPos The X Position to use.
     * @param yPos The Y Position to use.
     */
    public function new(xPos:Float = 0, yPos:Float = 0) {
        super();

        x = xPos;
        y = yPos;

        untyped __cpp__('
            this->data.ss = NULL;
            this->data.image = {NULL, NULL};
            Mtx_Identity(&this->data.matrix);
            C2D_PlainImageTint(&this->data.tint, 0xFFFFFFFF, 0);
        ');
    }

    /**
     * Creates a graphic from sprite to be ready to be rendered.
     * @param Width The width to set as.
     * @param Height The height to set as.
     * @param Col The color in hex 0xAARRGGBB to set as.
     */
    public function makeGraphic(Width:Float, Height:Float, Col:UInt32 = 0xFFFFFFFF) {
        width  = Width;
        height = Height;
        color  = Col;
    }

    /**
     * Loads an image graphic as a .t3x file
     * @param file File path to use, not needed to include `romfs:/` cause it does it for you, file must end with .t3x
     * @return true if successfully loaded, false if not loaded.
     */
    public function loadGraphic(file:String):Bool {
        untyped __cpp__('file = "romfs:/" + file; this->data.ss = C2D_SpriteSheetLoad(file.c_str())');
        if (untyped __cpp__("this->data.ss == NULL || this->data.ss == nullptr")) { 
            return false;
        }

        untyped __cpp__('
            C2D_Image ret = C2D_SpriteSheetGetImage(this->data.ss, 0);
            this->data.image = ret;
            this->width = ret.subtex->width;
            this->height = ret.subtex->height
        ');

        return true;
    }

    override function update(delta:Int) {
        super.update(delta);

        if (isDestroyed || !visible || alpha < 0) {
            return;
        }

        untyped __cpp__('
            int camP = 1;

            float newX = this->x, newY = this->y, newSW = this->scale->x, newSH = this->scale->x;
            if (this->camera != nullptr || this->camera != NULL) {
                newSW *= this->camera->_curZm;
                newSH *= this->camera->_curZm;
                newX = (newX * newSW) + this->camera->_xPtr;
                newY = (newY * newSH) + this->camera->_yPtr;
                camP++;
            }

            C2D_ViewSave(&this->data.matrix);
            C2D_ViewTranslate(newX * this->factor->x, newY * this->factor->y);
            C2D_ViewTranslate(this->width * newSW / 2, this->height * newSH / 2);
            C2D_ViewRotate(this->angle * M_PI / 180);
            C2D_ViewScale(newSW / camP, newSH / camP);
            C2D_ViewTranslate(-this->width / 2, -this->height / 2);

            if (this->data.image.tex == NULL || this->data.image.subtex == NULL) {
                u32 finalColor = colorConvert(this->color);
                if (this->alpha < 1) {
                    u8 a = (this->color >> 24) & 0xFF;
                    a = (u8)(a * this->alpha);
                    finalColor = (this->color & 0x00FFFFFF) | (a << 24);
                }
                C2D_DrawRectSolid(0, 0, 0, this->width, this->height, finalColor);
            } else {
                float result = std::fabsf((static_cast<float>(this->color & 0xFFFFFF) / 16777215.f) - 1);
                C2D_PlainImageTint(
                    &this->data.tint,
                    C2D_Color32(
                        (this->color >> 16) & 0xFF,
                        (this->color >> 8) & 0xFF,
                        this->color & 0xFF,
                        ((this->color >> 24) & 0xFF) * C2D_Clamp(this->alpha, 0, 1)
                    ),
                    result / 2
                );
                C2D_DrawImageAt(this->data.image, 0, 0, 0, &this->data.tint, 1, 1);
            }

            C2D_ViewRestore(&this->data.matrix)
        ');
    }

    override function destroy() {
        super.destroy(); 
        
        untyped __cpp__('
            if (this->data.ss != NULL) {
                C2D_SpriteSheetFree(this->data.ss);
                this->data.ss = NULL;
            }
        ');
    }
}