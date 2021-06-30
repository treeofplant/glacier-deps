--glacier's soundspace autoplayer
--made by Cyclops#0001
--might be outdated idfk

--setings
local maxLerpSpeed = 1; --make max lerp speed higher if ur doing on harder maps, i.e. dangerous slot (your perference)
local cursorTrail = true; --enable/disable cursor trail
 
--script
local gamescript = game.ReplicatedFirst.GameScript;
local c = workspace.Client.Cursor;
local getupvalue = getupvalue or debug.getupvalue;
local setupvalue = setupvalue or debug.setupvalue;
local setconstant = setconstant or debug.setconstant;
local u = getsenv(gamescript);
local r = getupvalue(u.ClearNotes, 1);
local updateSaber = u.UpdateSaber;
local cubeTree = {};
 
local tins = table.insert;
local rawset = rawset;
local cube = {
    __newindex = function(self, p, node)
        tins(cubeTree, { 
            node = node.MapCube;
            p = p;
        });
        return rawset(self, p, node);
    end;
};
 
--cursor trail script
do
    local renderCursorTrail = u.CursorTrail;
    getrenv()._G.trollPlayerData = {
        Settings = { CursorTrail = cursorTrail };
    };
    setconstant(renderCursorTrail, 7, 'trollPlayerData');
end;
 
do --lazy to set on cleanup
    local n = getsenv(game.ReplicatedFirst.SoundEngine);
    local oenable = n.EnableAll;
    n.EnableAll = function(t, b)
        if (b) then
            r = getupvalue(u.ClearNotes, 1);
            for p, node in pairs(r) do
                cubeTree[p] = node;    
            end;
            setmetatable(r, cube);
        end;
        return oenable(t, b);
    end;
end;
 
--saber hook
local pS = getupvalue(updateSaber, 1)();
setupvalue(updateSaber, 1, function()
    return pS;    
end);
 
--add cubes to tree
for p, node in pairs(r) do
    cubeTree[p] = node;    
end;
setmetatable(r, cube);
 
do --main
    local cam = workspace.CurrentCamera;
    local heartbeat = game:GetService('RunService').Heartbeat;
    local tpop = table.remove;
    local rand = Random.new;
    --local rseed = math.randomseed;
    local abs = math.abs;
    local floor = math.floor;
    local max = math.max;
    local tick = tick;
    local clamp = math.clamp;
    local elapsedCubeTime = 0;
    local lastMapTime = 0;
 
    heartbeat:Connect(function(frameDelta)
        if (#cubeTree > 0) then 
            local b = tpop(cubeTree, 1);
            local node = b.node;
            local p = b.p;
            if (r[p] ~= nil) then
               elapsedCubeTime = elapsedCubeTime + frameDelta;
               local v = Vector3.new(-p.Size.X / 2, (node.Y * 2) + 1, (node.Z * 2) - 2);
               local sm = (v - Vector3.new(-c.Size.X / 2, c.Position.Y, c.Position.Z)).magnitude;
               local t = (abs(node.Time - lastMapTime) / elapsedCubeTime); --omg just use math.noise
               do --for random uniform point in surface
                   local t = tick();
                   local b = max(node.Time - lastMapTime, 0);
                   local r = rand((t - (t % b) + b));
                   v = v + Vector3.new(r:NextNumber(), 0, 0);
               end;
               pS = pS:Lerp(CFrame.new(cam.CFrame.p, v), clamp(sm / (2 * t), 0.0, maxLerpSpeed));
               tins(cubeTree, 1, b);
            else
                lastMapTime = node.Time;
                elapsedCubeTime = 0;
            end;
        end;
    end);
end;
