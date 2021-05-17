--[[ 
 glacier ui color picker
 but with removed dragging/inbounds check part
 ~ Cyclops#0001
]]--

local uip = game:GetService('UserInputService');
local guiService = game:GetService('GuiService');

local piK = math.pi;
local sqrt = math.sqrt;
local pairs = pairs;
local unpack = unpack;
local atan2 = math.atan2;
local floor = math.floor;
local cose = math.cos;
local sine = math.sin;

local cR = script.Parent.Size.X.Offset / 2;
local pH = script.Parent.Size.Y.Offset;
local pX = script.Parent.AbsolutePosition.X;
local pY = script.Parent.AbsolutePosition.Y;
local constantB = 255; --hsb value const

local cursorPicker = script.Parent.pi;

--find relative hue to angle
local mapRelativeHue;
do
	local fromToPairMap = {
		[{0, 60}] = {0, 120},
		[{60, 120}] = {120, 180},
		[{120, 240}] = {180, 240},
		[{240, 360}] = {240, 360};
	};

	function mapRelativeHue(hue)
		hue = (180 * hue) / math.pi; --convert hue
		if (hue == 360) then
			return hue;
		end;

		local m0, m1, m2, m3 = 0, 0, 0, 0;
		for from, to in pairs(fromToPairMap) do
			local pmin, pmax = to[1], to[2];
			if (hue >= pmin and hue <= pmax) then --hue domain
				m0, m1 = pmin, pmax;
				m2, m3 = unpack(from);
				break;
			end;
		end;

		return m2 + (hue - m0) * ((m3 - m2) / (m1 - m0));
	end;
end;

--calculate hsv

do --uses hsb model
	local cabsP = cursorPicker.AbsolutePosition;
	local cabsS = cursorPicker.AbsoluteSize;
	
	local cX, cY = cabsP.X, cabsP.Y; --cabsP.X + (cabsS.X / 2), cabsP.Y + (cabsS.Y / 2);

	local x = floor((cX - pX) + 0.5);
	local y = floor((cY - pY) + 0.5);

	local drx, dry = cR - x, cR - y;
	
	local r = sqrt(drx * drx + dry * dry);
	local alpha = atan2(dry, drx); --reversed params (atan2)

	if (alpha < 0) then
		alpha = alpha + (2 * math.pi);
	end;

	if (r > cR) then --clamp
		r = cR;
		x = (r * (1 - cose(alpha)));
		y = (r * (1 - sine(alpha)));
	end;

	--for later use
	x = floor(x + 0.5);
	y = floor(y + 0.5);
	
	local h = mapRelativeHue(alpha);
	local s = floor((r / cR) * 255);
	
	--result : h, s, constantB
	script.Parent.Frame.BackgroundColor3 = Color3.fromHSV(h / 360, s / 255, constantB / 255);
end;
