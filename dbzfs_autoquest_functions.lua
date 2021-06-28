--[[ 
    some small functions from glacier's dbzfs autoquest that might help you make your own efficent autoquest.
    
    not my current code since it has been written bit long time ago with small optimizations later on
]]

local enum_quest_color = { -- made tostring cause of comparsion breaking
    requirement = tostring(Color3.fromRGB(255, 204, 0)); --defeat: etc
    completed = tostring(Color3.fromRGB(51, 204, 51));
    note = tostring(Color3.fromRGB(204, 51, 51)); --rewards:
    reward = tostring(Color3.new(1, 1, 1)); --Zenni, EXP
};

local function parse_requirements(quests_root) -- yeah this is old, new one is a class and just parses on initialization and has every function
    local requirement_struct = { };
    --[[
        overview for requirement_struct :
            set<string> interactions
            hashmap<string, int> defeats
    ]]
    local defeats, interactions = { }, { }; -- for faster access for both tables.
    requirement_struct.defeats = defeats;
    requirement_struct.interactions = interactions;
    for _, v in ipairs(quests_root:GetChildren()) do
        if (v.Name == 'Copy' and enum_quest_color.requirement == tostring(v.TextColor3)) then
            if (v.Text == 'Find ' or v.Text == 'Talk to') then -- why did he add a space to find..
                interactions[v.Num.Text] = true;
            else -- is a defeat?
                local to_defeat = string_match(v.Text, '^Defeat%s([%w%s%p]-)s?$');
                if (to_defeat ~= nil) then
                    defeats[to_defeat] = tonumber(v.Num.Text);
                end
            end
        end
    end
    return requirement_struct;
end

local function populate_interaction_stack(root)
    -- assuming interaction as an unsorted binary tree, where left node is continue interaction with npc and right is stop.
    local interaction_stack = { }; -- assuming LIFO stack
    root = root.Parent;
    while (root ~= nil) do
        local name = root.Name;
        if (name == 'Chat') then
            if (root.ClassName == 'Folder') then
                break;
            end
            table_insert(interaction_stack, 1, 'k'); -- push to begin, we could also push Chat instead (epic moment)
        elseif (name ~= 'Choice' and root.ClassName ~= 'Folder') then
            table_insert(interaction_stack, 1, name);
        end
        root = root.Parent;
    end
    return interaction_stack;
end
