-- glacier simple remotespy
-- a simple remotespy i made in some hours to use in my project
-- author: Cyclops#0001


--some little todo: avoid some attack vectors to detect the remotespy

local tbpk = table.pack;
local method_map = {
    ['RemoteEvent'] = 'FireServer';
    ['RemoteFunction'] = 'InvokeServer';
    ['BindableEvent'] = 'Fire';
    ['BindableFunction'] = 'Invoke';
};

--%q is fucked up really lua?
local escape;
do
    local esc = {
        ['\0'] = '\\0'; -- wont affect within c calls
        ['\n'] = '\\n';
        ['\t'] = '\\t';
        ['\v'] = '\\v';
        ['\\'] = '\\\\';
    };
    local tins = table.insert;

    do
        local char = string.char;
        local strfmt = string.format;
        for i = 1, 32 do
            if (i < 9 or i > 11) then
                esc[char(i)] = strfmt('\\%X', i);
            end
        end
        
        for i = 126, 255 do
            esc[char(i)] = strfmt('\\%X', i);
        end
    end
    
    function escape(str)
        local strstream = {};
        for f, l in utf8.graphemes(str) do
            local g = str:sub(f, l);
            if (g == '"') then
                g = '\"';
            end;
            g = g:gsub('[^\32-\126]*[\\v\\t\\n\\r\\]?', esc);
            tins(strstream, g);
        end
        return table.concat(strstream, '');
    end
end

local get_full_name;
do
    local tins = table.insert;
    local tcat = table.concat;
    local stsb = string.sub;
    local stfmt = string.format;
    local stmatch = string.match;
    local common_start = 'game';
    local game = game;
    local workspace = workspace;
    
    --[[
        \brief o - Instance to get the full name
        \return Unknown string - full name of instance
    ]]

    function get_full_name(o) --o = temp object
        local parent_tree = {};
        if (o.Parent == nil) then
            return 'nil';
        end
        -- tail call optimization ( not recursing till the root node unlike the others )
        while (o.Parent ~= nil) do
            local n = o.Name;
            local p = o.Parent;
            if (stmatch(n, '[^%a%d_]')) then -- ([^%a%d_]) seems to be more efficent than (%W)?
                n = stfmt('[%q]', n);
                tins(parent_tree, 1, n);
            elseif (p == game) then
                if (n == workspace) then
                    tins(parent_tree, 1, 'workspace');
                    return tcat(parent_tree); --lazy to contiune traversing from there
                else
                    tins(parent_tree, 1, stfmt(':GetService(%q)', n));
                end
            else
                tins(parent_tree, 1, '.' .. n);
            end
            o = p; -- o = o.Parent
        end
        return common_start .. tcat(parent_tree);
    end
end

--[[
    \brief ( args... ) -> unknown tuple parameters
    \return - a string that is based on the input tuple ( stringified tuple ) too lazy to explain asd
]]

local parameter_visitor; --local argument_convert;
do
    --todo: work on only replicated types: number, strings, tables, bool, etc
    local stfmt = string.format;
    local typeof = typeof;
    local tins = table.insert;
    local pairs = pairs;
    local tostring = tostring;
    local tcat = table.concat;

    local format_constructor_map = { --roblox's custom userdata data types ( everything looks like this till i actually change something )
        ['Color3'] = 'Color3.new(%s)'; --'Color3.new(%u, %u, %u)';
        ['ColorSequence'] = 'ColorSequence.new(%s)';
        ['BrickColor'] = 'BrickColor.new(%s)';
        ['Vector3'] = 'Vector3.new(%s)';
        ['Region3'] = 'Region3.new(%s)';
        ['CFrame'] = 'CFrame.new(%s)';
        ['PathWaypoint'] = 'PathWaypoint.new(%s)';
        ['NumberRange'] = 'NumberRange.new(%s)';
        ['UDim'] = 'UDim.new(%s)';
        ['UDim2'] = 'UDim2.new(%s)';
        ['Rect'] = 'Rect.new(%s)';
        --tweeninfo todo
        --todo: will ray replicate?
    };

    local for_types = {
        ['string'] = true;
        ['coroutine'] = true;
        ['function'] = true;
        ['userdata'] = true;
    };

    --todo: table indenter (beautifier)
    local function convert_table(t) -- another function because argument only allows ordered
        local string_table = {};

        -- conv array partition
        for i = 1, #t, 1 do -- optimization to ipairs?
            local v = t[i];
            local tt = typeof(v);
            do
                local formatted_arg = parameter_visitor(v);
                tins(string_table, formatted_arg);
            end
            t[i] = nil; -- might cause undefined behavior?
        end

        -- conv hash partition
        for k, v in pairs(t) do
            local start = stfmt('[%s] = ', parameter_visitor(k));
            do
                local formatted_arg = start .. parameter_visitor(v);
                tins(string_table, formatted_arg);
            end
        end

        return tcat(string_table, ', ');
    end

    function parameter_visitor(v)
        local tt = typeof(v);
        --switch for the types we need to actually handle in this case
        if (for_types[tt]) then
            return stfmt('"%s"', escape(tostring(v)));
        elseif (tt == 'table') then
            return stfmt('{ %s }', convert_table(v));
        elseif (tt == 'boolean') then
            return (v and 'true' or 'false'); --faster than tostr
        elseif (tt == 'Instance') then
            return get_full_name(v);
        else
            local constructor_start = format_constructor_map[tt];
            if (constructor_start) then
                return stfmt(constructor_start, tostring(v)); -- construct element as string and return the string
            end
        end
        return tostring(v);
    end

    --[[function argument_convert(args) -- small code but won't mind performance
        for i = 1, args.n do
            args[i] = parameter_visitor(args[i]);
        end
        return tcat(args, ', ');
    end]]
end

local generate_script;
do
    local tins = table.insert;
    local tcat = table.concat;
    local stfmt = string.format;
    local typeof = typeof;

    function generate_script(info) -- arg info : { instance = x, parameters = packedt }
        local result = { '-- script generated by glacier remotespy:tm:\n' };
        local instance = info.instance;
        if (instance ~= nil and typeof(instance) == 'Instance') then
            local method = method_map[instance.ClassName];
            if (method ~= nil) then
                tins(result, get_full_name(instance));
                do
                    local formatted_params = info.parameters;
                    for i = 1, formatted_params.n do
                        formatted_params[i] = parameter_visitor(formatted_params[i]);
                    end
                    tins(result, stfmt(':%s(%s)', method, tcat(formatted_params, ', ')));
                    formatted_params = nil;
                end
            else
                tins(result, ' -- error: method in method map is nil?\n');
            end
        else
            tins(result, '-- error: instance param is nil or is not an instance?\n')
        end
        return info.callback(tcat(result));
    end
end


--safe thread schulder ( i made from march 2021 glacier )
local remote_schulder = {};
do 
    local stepped = game:GetService('RunService').Stepped;
    local ipairs = ipairs;
    local tpop = table.remove;
    local tins = table.insert;
    local remote_schulder_jobs = { };
    local MODE_V_MT = { __mode = 'v' };
    remote_schulder.__index = remote_schulder;

    function remote_schulder:clear() --inline asd
        for i, v in ipairs(remote_schulder_jobs) do
            v:deconstruct();
            v = nil;
        end
        table.clear(remote_schulder_jobs);
    end

    function remote_schulder:deconstruct()
        local schulder_connection = self.schulder_connection;
        if (schulder_connection) then
            schulder_connection:Disconnect();
            schulder_connection = nil;
        end
        table.clear(self.thread_deque);
    end

    function remote_schulder:enqueue(o)
        o.co = coroutine.create(generate_script);
        return tins(self.thread_deque, o); --push node to front
    end

    function remote_schulder.new()
        local thread_deque = setmetatable({ }, MODE_V_MT);  --ordered list (priority time)
        if (#remote_schulder_jobs > 0) then --cleanup
            remote_schulder:clear();
        end
        local schulder_init = setmetatable({
            schulder_connection = stepped:Connect(function()
                if (#thread_deque == 0) then
                    return;
                end
                local busy_thread = tpop(thread_deque, 1); --threads
                --todo checks

                if (busy_thread.instance ~= nil) then --do
                    return assert(coroutine.resume(busy_thread.co, busy_thread), 'couldnt resume (error generate script schulder)'); --unless await
                --end
                end
                tins(thread_deque, 1, busy_thread); --push busy thread to back again
            end);
            thread_deque = thread_deque;
            alive = true;
        }, remote_schulder);
        tins(remote_schulder_jobs, schulder_init);
        return schulder_init;
    end
end

--example

rconsoleclear();
local remoteschud = remote_schulder.new();
do --only namecall support atm
    local cb = function(ret)
        rconsolewarn(ret); -- testing
    end

    local getnamecallmethod = getnamecallmethod;
    local mt = getrawmetatable(game);
    local oldnc = mt.__namecall;
    setreadonly(mt, false);
    mt.__namecall = newcclosure(function(self, ...)
        local m = method_map[self.ClassName];
        if (m and getnamecallmethod() == m and self.Parent ~= nil) then
            remoteschud:enqueue({
                instance = self;
                parameters = tbpk(...);
                callback = cb;
            });
        end
        return oldnc(self, ...);
    end)
end
