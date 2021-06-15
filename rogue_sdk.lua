--[[
    glacier rogue lineage SDK (remotes for script, etc).
    full rogue bypass is written aswell & full ban bypass (not shitty like all other methods, better than cornage and elym)

    note to rogue devs: have fun patching this one ;-)
    ~ Cyclops#0001

    https://discord.io/glacier_
]]

local game = game;
local g_mt = getrawmetatable(game);
local players = game:GetService('Players');
local lighting = game:GetService('Lighting');
local local_player = players.LocalPlayer;
local run_service = game:GetService('RunService');
local replicated_storage = game:GetService('ReplicatedStorage');
local remote_fireserver = Instance.new('RemoteEvent').FireServer;
local debug_assert = assert; -- replaced debug_assert with something else for now

-- keyhandler bypass
local keyhandler = { };
do
    local keyhandler_script = replicated_storage.Assets.Modules.KeyHandler;

    -- update check?
    local latest_keyhandler_checksum = '082d0ac8b31be577c717ceac49ba57fdbdc2fcf23206fd4dfc1fdb22818962d0b95e655681f4d9f9bc584b365cff83b6';
    debug_assert(getscripthash(keyhandler_script) == latest_keyhandler_checksum, '[error-glacier-sdk-init]: invalid checksum'); -- if is debugging?

    -- keyhandler start function
    local keyhandler_main = require(keyhandler_script);
    
    -- floating point error keys ( specific keys that break comparsion while being passed because of long fpu artimethic, the game choosed those specific keys for their own security )
    local fpe_key_map = { -- to get : for l in s:gmatch('u21%b()') do l:gsub('[%l%d_]-%(%s*[%l%d_]+%((%d+)%):sub%(%d+,%s?%d+%)%s*%)', '%1') end
        ['Tango'] = (51 * 54 * (72 % (36 * (54 + 65 + 22 * 41 + 18 / 65 * 68 / 20 * 70 + 2) % 25 * 7 * 7 % 5 % 64 % 41 / 66 + 33 % 21) / 54 / (4 % 36 / 36 + 3 * 49 / 53 / 72 * 39 / 7 * 25) + 67 % 6 * 4 % 52 * 21 / 4 % 35 / 3) / 35 * 38 + (66 + (56 % 16 + 4 + 5 + 2 + 51 * 23 / 57 * 25 * 37) / 34 + 40 % 71 % 41 / 56 % 65 * 57 + 69 * 49) + 21 * 20 + 35 * (23 / 73 % 65 + 69 + 33 % 19 / 56 + 67 % 39 + 36) + 25 / 8 % 18);
        ['ApplyFallDamage'] = (5 * (80 + 6 * 73 / (64 + 20 * 37 * (52 + 22 + 69 / 55 / 64 + 18 % 35 * 37 + 33 % 4) * 56 / 32 / 66 % 9 % 16 * 80 * 16) % 33 % 2 % 35 / (2 / 23 % 37 * 54 * 2 % 57 % 67 / 54 % 34 + 72) * 33 / 32 / 67 * 37) % 72 % 18 % 16 * 80 * (17 / (39 / 39 * 68 * 22 % 64 * 16 * 25 * 41 % 34 / 38) + 69 * 23 + 23 % 3 * 48 + 68 % 33 / 70 * 41) % 51 / (73 / 21 + 32 % 32 % 35 % 19 / 5 + 34 % 21 + 68) % 39 * 24 + 52 + 33);
        ['SetManaChargeState'] = (72 / 32 + 80 % 38 % (50 * (3 / 73 * 64 * (7 * 23 + 51 / 39 % 41 + 23 + 70 * 73 * 73 / 68) + 22 * 73 / 25 / 49 / 40 * 68 % 5) * 3 / 2 / 2 * 41 + 32 % (33 + 67 * 41 + 40 * 48 / 71 % 36 + 3 * 48 + 22) % 18 + 19 * 66 / 16) * 35 * (19 + 73 % 80 * (37 % 34 + 49 / 4 % 70 * 53 * 64 % 7 % 73 % 21) / 8 * 35 % 64 * 34 + 23 / 56 * 53) % 56 * (18 / 73 * 49 + 40 / 73 / 72 / 70 / 17 % 9 / 40) % 49 + 49 % 9 / 65);
        ['Dodge'] = (5 / (52 / (17 / (17 * 18 / 52 / 51 % 24 % 20 * 72 * 35 + 51 % 70) % 22 % 36 * 7 % 18 + 23 % 20 / 36 + 8 * 64) * 6 * 73 / (41 % 22 / 56 / 67 + 20 * 24 + 24 / 65 / 51 + 68) + 67 / 2 + 41 % 53 / 20 / 57 + 38) / 38 % 8 / 55 * 48 / 16 + 18 * 22 % (39 * 23 * (38 % 17 * 23 * 64 % 19 + 36 * 72 + 7 * 38 / 50) / 2 + 37 + 23 / 54 % 32 * 32 + 55 * 56) + 65 % 9);
    };

    -- patcher
    local patcher_class, patcher_job = { }, { };
    patcher_class.__index = patcher_class;
    patcher_job.__index = patcher_job;
    
    do
        local patcher_singleton; -- shared resource

        -- localizations ( vm optimization )
        local setmetatable = setmetatable;
        local table_clear = table.clear;
        local ipairs = ipairs;
        local type = type;

        -- utility constants for psu ( prob wont change per obfuscation )
        local register_bx_k = 639954; -- (b&c)
        local register_a_k = -50014; --a
        local proto_next_k = 'TI8';
        local stack_next_k = 'sBgaL';
        local rel_k = 'jDWh3';

        --patcher job
        function patcher_job:resolve()
            if (self.resolved_) then
                return;
            end

            local proto_idx, stk_idx;
            for i, v in ipairs(self.code_) do
                if (type(v) == 'table') then
                    local entry_node = v[0];
                    if (entry_node and type(entry_node) == 'table') then
                        if (entry_node[proto_next_k]) then
                            proto_idx = i;
                        elseif (entry_node[stack_next_k]) then
                            stk_idx = i;
                        end
                    end
                end
                if (proto_idx and stk_idx) then
                    self.stk_idx_ = stk_idx;
                    self.proto_idx_ = proto_idx;
                    break;
                end
            end
            self.resolved_ = true;
        end

        function patcher_job:get_resolved()
            return self.resolved_;
        end

        function patcher_job:get_protos()
            return self.code_[self.proto_idx_];
        end

        function patcher_job:get_stk()
            return self.code_[self.stk_idx_];
        end

        function patcher_job:init(code) -- move construct code
            return setmetatable({
                code_ = code;
                stk_idx_ = nil;
                proto_idx_ = nil;
            }, patcher_job);
        end
        
        function patcher_job:destruct()
            self.code_ = nil;
            self.resolved_ = false;
            self.stk_idx_ = nil;
            self.proto_idx_ = nil;
            self = nil;
        end

        --patcher class

        local enum_patcher_state = {
            idle = 0;
            running = 1;
            dead = 2;
        };

        function patcher_class:get_state()
            return self.state_;
        end

        function patcher_class:set_state(state)
            self.state_ = state;
        end

        function patcher_class:resolve_symbols()
            -- todo
        end

        function patcher_class:get_singleton()
            if (patcher_singleton == nil) then
                patcher_singleton = patcher_class:init();
            end
            return patcher_class;
        end

        function patcher_class:init()
            return setmetatable({
                -- running_jobs_ = { };
                patcher_job_ = nil; -- composited patcher job struct
                state_ = nil;
            }, patcher_class);
        end

        function patcher_class:patch_stack()
            if (self.patcher_job_ == nil) then
                return false;
            end

            local found_flag = false;
            local node, prev = self.patcher_job_:get_stk()[0];
            while (node ~= nil) do
                local val = node[register_a_k];
                if (val == '\n' or val == '\n\n' and prev and prev[register_bx_k] == 'gsub') then -- dont break here
                    found_flag = true;
                    node[register_a_k] = '.'; -- epic hack
                end
                -- restore prev since singly linkedlist
                prev = node;
                node = node[stack_next_k];
            end
            return found_flag;
        end

        function patcher_class:patch_protos() -- todo better code
            if (self.patcher_job_ == nil) then
                return false;
            end

            for _, prt in ipairs(self.patcher_job_:get_protos()) do
                local proto_code = prt[proto_next_k];
                if (proto_code ~= nil) then
                    local node, prev = proto_code[0];
                    while (node ~= nil) do -- patch loop
                        if (node[register_bx_k] == 'HttpGet') then -- strings cus constants are already loaded
                            node[register_bx_k] = 'HttpGetfucking nigger';
                            break;
                        elseif (node[register_a_k] == '' or node[register_a_k] == '\r') then
                            table_clear(prt);
                            break;
                        else
                            -- local register_map = node['jEu9Q'];
                            if (type(node[rel_k]) == 'table') then -- call? {[0] = 1, [1] = 2}
                                local target_node = node[stack_next_k][stack_next_k]; 
                                -- fixed?
                                if (target_node ~= nil and target_node[register_bx_k] == '') then -- skip pc somehow
                                    node[register_a_k] = -1;
                                    break;
                                end
                            elseif (node[register_a_k] == 11 and prev) then -- fuck the forprep instr after it
                                node[register_a_k], prev[register_a_k] = 0, 1;
                                break;
                            end
                        end
                        prev = node;
                        node = node[stack_next_k];
                    end
                end
            end
            return true;
        end

        function patcher_class:full_patch()
            if (not self.patcher_job_:get_resolved()) then
                self.patcher_job_:resolve();
            end

            if (not self:patch_stack() or not self:patch_protos()) then
                return false;
            end
            
            -- destruct the patcher job
            self.patcher_job_:destruct();
            self.patcher_job_ = nil;

            self:set_state(enum_patcher_state.finished);
            return true;
        end

        function patcher_class:get_job()
            return self.patcher_job_;
        end
        
        function patcher_class:set_job(job)
            self.patcher_job_ = job;
        end

        function patcher_class:destruct()
            self.patcher_job_ = nil;
            self.state_ = nil;
            self = nil;
        end
    end

    -- main (patch, etc)
    local patcher_singleton = patcher_class:get_singleton();

    --couldv'e made a function for this tbh
    do -- patch keyhandler_main
        local new_job = patcher_job:init(getupvalues(keyhandler_main));

        patcher_singleton:set_job(new_job);
        if (not patcher_singleton:full_patch()) then
            return;
        end
    end
    
    local get_key, set_key = unpack(keyhandler_main()); -- get, set

    do -- patch get key
        local new_job = patcher_job:init(getupvalues(get_key));

        patcher_singleton:set_job(new_job);
        if (not patcher_singleton:full_patch()) then
            return;
        end
    end

    -- set key has no checkers, good

    keyhandler.get_key, keyhandler.set_key = function(key, verification) -- todo safety?
        verification = verification or 'plum';
        --[[
            if (memoized_keys[key]) then
                return memoized_keys[key];
            end
        ]]
        return get_key(fpe_key_map[key] or key, verification);
    end, set_key;
end

-- keys that will be used in the script :

-- ~ game important keys :
local tango_remote = keyhandler.get_key('Tango', 'plum');
local fall_remote = keyhandler.get_key('ApplyFallDamage', 'plum');
local setmana_remote = keyhandler.get_key('SetManaChargeState', 'plum');
local dodge_remote = keyhandler.get_key('Dodge', 'plum');
-- ~ general keys :
local theodora_remote = keyhandler.get_key('Theodora', 'plum');
local stopclimb_remote = keyhandler.get_key('StopClimb', 'plum');
local placetool_remote = keyhandler.get_key('PlaceTool', 'plum');
local wakeup_remote = keyhandler.get_key('WakeupSleep', 'plum');

-- anti ban bypass
do
    local destroy_descriptor_func = game.Destroy;
    local find_first_child = game.FindFirstChild;
    local coro_wrap = coroutine.wrap;
    local rawget = rawget;
    local replaceclosure = replaceclosure;
    local islclosure = islclosure;
    local getupvalues = debug.getupvalues;
    local typeof = typeof;

    -- external hook restores
    local o_destroy, o_anim_play, o_status, o_fireserver;
    local o_newindex = g_mt.__newindex;
    local o_namecall = g_mt.__namecall;

    setreadonly(g_mt, false);

    -- animation hook
    do
        -- control variables
        local is_a = game.isA;

        local temp_humanoid = game:FindFirstChildWhichIsA('Humanoid', true);
        debug_assert(temp_humanoid, 'failed to find temp humanoid [animation_hook]');

        local temp_anim = Instance.new('Animation');
        temp_anim.AnimationId = 'rbxassetid://4595066903';

        local loaded_anim = temp_humanoid:LoadAnimation(temp_anim);
        local anim_play = loaded_anim.Play;
        loaded_anim:Destroy();
        loaded_anim = nil;

        o_anim_play = replaceclosure(anim_play, newcclosure(function(self, ...) -- varargs cus args might be missing sometimes and it may cause edge case errors ( lua dumb )
            if (self and typeof(self) == 'Instance' and is_a(self, 'AnimationTrack') and self.Animation.AnimationId == 'rbxassetid://4595066903') then
                --debug_print('ban call stack?:'.. debug.traceback('', 3));
                return;
            end
            return o_anim_play(self, ...);
        end));
    end

    -- destroy hook
    o_destroy = replaceclosure(destroy_descriptor_func, newcclosure(function(self)
        if (self and typeof(self) == 'Instance' and self.Name == 'CharacterHandler') then
            -- todo make this statement body a function?
            local lp_char = local_player.Character;
            if (lp_char ~= nil) then
                if (self == lp_char) then
                    return;
                end
                local char_handler = find_first_child(lp_char, 'CharacterHandler');
                if (self == char_handler) then
                    return;
                end
                local input = find_first_child(char_handler, 'Input');
                if (self == input) then
                    return;
                end
            end
        end
        return o_destroy(self);
    end));

    -- coro hook
    do
        local coroutine_status_map = setmetatable({ }, { __mode = 'k' });

        o_fireserver = replaceclosure(remote_fireserver, newcclosure(function(self, remote_data, ...)
            if (self == tango_remote and typeof(remote_data) == 'table') then -- filter ban remote
                local x = rawget(remote_data, 2);
                if (not x or typeof(x) ~= 'number' or x < 2.05 or x > 3.95) then -- m = 2.05, n = 3.95
                    local coro_ = coroutine.running();
                    if (coro_ == nil) then
                        return;
                    end
                    coroutine_status_map[coro_] = 'dead';
                    -- setfenv wouldn't be good since call stack has less values cus coroutine
                    return coroutine.yield(); -- make coroutine suspended (status will be dead, and then can't be re-resumed)
                end
            end

            return o_fireserver(self, remote_data, ...);
        end));

        o_status = replaceclosure(coroutine.status, newcclosure(function(coro_)
             if (coro_ ~= nil) then
                local coro_status_ = coroutine_status_map[coro_];
                if (coro_status_ ~= nil) then
                    coroutine_status_map[coro_] = nil;
                    do
                        -- here we should stop the crash coroutine from running ( 99.99% precentage that it will be a crash coroutine, may be always i'm not sure? ) ( retarded method smh )
                        local o_coro_wrap;
                        o_coro_wrap = replaceclosure(coro_wrap, newcclosure(function(co_task) -- recurse + mem leak
                            if (co_task and typeof(co_task) == 'function' and islclosure(co_task)) then
                                local upv = getupvalues(co_task);
                                if (#upv == 1 and upv[1] == run_service) then
                                    replaceclosure(coro_wrap, o_coro_wrap);
                                    o_coro_wrap = nil;
                                    return (function() end);
                                end
                            end

                            replaceclosure(coro_wrap, o_coro_wrap);
                            o_coro_wrap = nil;
                            return coro_wrap(co_task);
                        end));
                    end
                    return coro_status_;
                end
             end
             return o_status(coro_);
        end));
    end

    -- metatable hooks
    g_mt.__newindex = newcclosure(function(self, k, v) -- cringe i will optimize
        if (v == nil and k == 'Parent' and self and typeof(self) == 'Instance') then
            -- same code as in destroy hook
            local lp_char = local_player.Character;
            if (lp_char ~= nil) then
                if (self == lp_char) then
                    return;
                end
                local char_handler = find_first_child(lp_char, 'CharacterHandler');
                if (self == char_handler) then
                    return;
                end
                local input = find_first_child(char_handler, 'Input');
                if (self == input) then
                    return;
                end
            end
        end
        return o_newindex(self, k, v);
    end);
end

-- ROGUE SDK END

-- example code
rconsoleprint('bypassed bans!\r\n');
rconsolewarn('tango_remote: '.. tango_remote.Name);
rconsolewarn('fall_remote: '.. fall_remote.Name);
rconsolewarn('dodge_remote: '.. dodge_remote.Name);
rconsolewarn('theodora_remote: '.. theodora_remote.Name);
rconsolewarn('stopclimb_remote: '.. stopclimb_remote.Name);
rconsolewarn('placetool_remote: '.. placetool_remote.Name);
rconsolewarn('wakeup_remote: '.. wakeup_remote.Name);
