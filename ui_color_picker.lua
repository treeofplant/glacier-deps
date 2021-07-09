--[[ 
 glacier ui color picker
 but with removed dragging part which is only 20 small lines with nothing lol

 notice this is made for glacier ( my own Script Hub )'s ui library.

 testing : https://cdn.discordapp.com/attachments/819718479627943966/843541085845979176/UkLVKGwtMH.gif
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

local cR = script.Parent.Size.X.Offset / 2; -- circle radius
local pH = script.Parent.Size.Y.Offset;
local pX = script.Parent.AbsolutePosition.X;
local pY = script.Parent.AbsolutePosition.Y;
local constantV = 255; --hsv value const

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
		end

		local m0, m1, m2, m3 = 0, 0, 0, 0;
		for from, to in pairs(fromToPairMap) do
			local pmin, pmax = to[1], to[2];
			if (hue >= pmin and hue <= pmax) then --hue domain
				m0, m1 = pmin, pmax;
				m2, m3 = unpack(from);
				break;
			end
		end

		return m2 + (hue - m0) * ((m3 - m2) / (m1 - m0)); -- interpolation
	end
end

do --uses hsv model
	--what we need to do: get the hue and saturation from the circle using our data in this problem.
	local cabsP = cursorPicker.AbsolutePosition;
	local cabsS = cursorPicker.AbsoluteSize;
	
	--lets pretend cX, cY are our current input position, couldv'e used vector2 to represent the plot with a more correct type aswell.
	local cX, cY = cabsP.X, cabsP.Y; --cabsP.X + (cabsS.X / 2), cabsP.Y + (cabsS.Y / 2);

	-- convert the position plot into element's space (relative from the viewport) and round it.
	local x = floor((cX - pX) + 0.5);
	local y = floor((cY - pY) + 0.5);

	-- a new plot, lets make a new triangle across the diameter of the circle ( makes it a 90 degree because arcs to diameter, simple circle theorems. )
	local drx, dry = cR - x, cR - y;
	--also will be our slope
	
	local r = sqrt(drx * drx + dry * dry); -- [drx^2 + dry^2 = r^2] ( find radius using pytahgoras )
	local alpha = atan2(dry, drx); -- find the positive angle when we got (drx, dry), also this will be similar to arctan(m aka slope), ( used for hue later )

	if (alpha < 0) then -- alpha got negative, and since atan2 domain must be [0 < res < 2pi] we add +2pi, we dont need a while loop here since alpha wouldn't be that big.
		alpha = alpha + (2 * math.pi); -- transform alpha
	end

	-- radius normalization
	if (r > cR) then --radius is over the normal circle's radius?
		r = cR;
		-- lets pretend we have a unit circle inside, x is cose(theta), y is sine(theta), h/r is 1 since is unit.
		-- we use trigo identifies then we normalize the circle using multiplying our normal radius with the result.
		x = (r * (1 - cose(alpha)));
		y = (r * (1 - sine(alpha)));
	end

	local h = mapRelativeHue(alpha); -- map to relative hue using our algorithm
	local s = floor((r / cR) * 255); -- convert to 255%'s to round s to 255 later on ( could been probably done with modulo for more optimization )
	
	--result : h, s, constantB
	cursorPicker.Position = UDim2.fromOffset(x, y); --cursorPicker variable has been in the original version
	script.Parent.Frame.BackgroundColor3 = Color3.fromHSV(h / 360, s / 255, constantV / 255);
end
