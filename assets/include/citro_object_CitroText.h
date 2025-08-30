#pragma once

#include <cstdint>
#include <memory>
#include <string>
#include "_HaxeUtils.h"
#include "citro_object_CitroObject.h"
#include <3ds.h>
#include <citro2d.h>
#include <citro3d.h>

namespace citro::object {

class CitroText: public citro::object::CitroObject {
public:
	C2D_Font defaultFont;
	C3D_Mtx matrix;
	std::string text;
	int borderStyle;
	int alignment;
	double borderSize;
	uint32_t borderColor;
	bool wordWrap;

	CitroText(double xPos = 0, double yPos = 0, std::string Text = std::string(""));
	void update(int delta) override;
	bool loadFont(std::string path);
	void destroy() override;

	HX_COMPARISON_OPERATORS(CitroText)
};
}