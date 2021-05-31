-- Textline: wide character displays for Minetest, controlled with Digilines
-- Based on the LCD that comes with Digilines
-- Copyright 2017 Gabriel Maia <gabriel@tny.im>, http://github.com/gbl08ma
-- Copyright 2017 Segvault http://segvault.tny.im
-- See the included license file LICENSE.txt
-- Font: 04.jp.org

textline = {}
-- load characters map
local chars_file = io.open(minetest.get_modpath("textline").."/characters", "r")
local charmap = {}
local max_chars = 27
if not chars_file then
    print("[textline] E: character map file not found")
else
    while true do
        local char = chars_file:read("*l")
        if char == nil then
            break
        end
        local img = chars_file:read("*l")
        chars_file:read("*l")
        charmap[char] = img
    end
end

local textlines = {
    -- on ceiling
    --* [0] = {delta = {x = 0, y = 0.4, z = 0}, pitch = math.pi / -2},
    -- on ground
    --* [1] = {delta = {x = 0, y =-0.4, z = 0}, pitch = math.pi /  2},
    -- sides
    [2] = {delta = {x =  0.43, y = 0, z = 0}, yaw = math.pi / -2},
    [3] = {delta = {x = -0.43, y = 0, z = 0}, yaw = math.pi /  2},
    [4] = {delta = {x = 0, y = 0, z =  0.43}, yaw = 0},
    [5] = {delta = {x = 0, y = 0, z = -0.43}, yaw = math.pi},
}

local reset_meta = function(pos)
    minetest.get_meta(pos):set_string("formspec", "field[channel;Channel;${channel}]")
end

local clearscreen = function(pos)
    local objects = minetest.get_objects_inside_radius(pos, 0.5)
    for _, o in ipairs(objects) do
        if o:get_luaentity() and o:get_luaentity().name == "textline:text" then
            o:remove()
        end
    end
end

local prepare_writing = function(pos)
    local lcd_info = textlines[minetest.get_node(pos).param2]
    if lcd_info == nil then return end
    local text = minetest.add_entity(
        {x = pos.x + lcd_info.delta.x,
         y = pos.y + lcd_info.delta.y,
         z = pos.z + lcd_info.delta.z}, "textline:text")
    text:set_yaw(lcd_info.yaw or 0)
    return text
end

local on_digiline_receive = function(pos, node, channel, msg)
    local meta = minetest.get_meta(pos)
    local setchan = meta:get_string("channel")
    if setchan ~= channel then return end

    meta:set_string("text", msg)
    if msg ~= "" then
        local text = meta:get_string("text")
        local objects = minetest.get_objects_inside_radius(pos, 0.5)
        for _, o in ipairs(objects) do
            local lentity = o:get_luaentity()
            if lentity ~= nil then
                local lname = lentity.name
                if lname ~= nil and lname == "textline:text" then
                    o:set_properties({textures={textline:generate_texture(textline:create_lines(text))}})
                end
            end
        end
    end
end

local lcd_box = {
    type = "wallmounted",
    wall_top = {-8/16, 7/16, -8/16, 8/16, 8/16, 8/16}
}

minetest.register_node("textline:lcd", {
    drawtype = "nodebox",
    description = "Textline",
    inventory_image = "textline_icon.png",
    wield_image = "textline_icon.png",
    tiles = {"textline_anyside.png"},

    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    node_box = lcd_box,
    selection_box = lcd_box,
    groups = {choppy = 3, dig_immediate = 2, not_blocking_trains = 1},

    after_place_node = function (pos, placer, itemstack)
        local param2 = minetest.get_node(pos).param2
        if param2 == 0 or param2 == 1 then
            minetest.add_node(pos, {name = "textline:lcd", param2 = 3})
        end
        prepare_writing (pos)
    end,

    on_construct = function(pos)
        reset_meta(pos)
    end,

    on_destruct = function(pos)
        clearscreen(pos)
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        if (fields.channel) then
            minetest.get_meta(pos):set_string("channel", fields.channel)
        end
    end,

    _digistuff_channelcopier_fieldname = "channel",

    digiline =
    {
        receptor = {},
        effector = {
            action = on_digiline_receive
        },
    },

    light_source = 0,
})

minetest.register_node("textline:hud", {
    drawtype = "airlike",
    description = "Transparent Textline",
    inventory_image = "textline_hud.png",
    wield_image = "textline_hud.png",
    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    node_box = lcd_box,
    selection_box = lcd_box,
    groups = {choppy = 3, dig_immediate = 2, not_blocking_trains = 1},

    after_place_node = function (pos, placer, itemstack)
        local param2 = minetest.get_node(pos).param2
        if param2 == 0 or param2 == 1 then
            minetest.add_node(pos, {name = "textline:hud", param2 = 3})
        end
        prepare_writing(pos)
    end,

    on_construct = function(pos)
        reset_meta(pos)
    end,

    on_destruct = function(pos)
        clearscreen(pos)
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        if (fields.channel) then
            minetest.get_meta(pos):set_string("channel", fields.channel)
        end
    end,

    _digistuff_channelcopier_fieldname = "channel",

    digiline =
    {
        receptor = {},
        effector = {
            action = on_digiline_receive,
        },
    },

    light_source = 0,
})

minetest.register_node("textline:background", {
    drawtype = "nodebox",
    description = "Textline background",
    inventory_image = "textline_background.png",
    wield_image = "textline_background.png",
    tiles = {"textline_anyside.png"},

    paramtype = "light",
    sunlight_propagates = true,
    paramtype2 = "wallmounted",
    node_box = lcd_box,
    selection_box = lcd_box,
    groups = {choppy = 3, dig_immediate = 2, not_blocking_trains = 1},

    light_source = 0,
})

minetest.register_entity("textline:text", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    visual_size = {x=3, y=1},
    textures = {},

    on_activate = function(self)
        local meta = minetest.get_meta(self.object:get_pos())
        local text = meta:get_string("text")
        self.object:set_properties({textures={textline:generate_texture(textline:create_lines(text))}})
    end
})

-- CONSTANTS
local LCD_WIDTH = 160
local LCD_HEIGHT = 34
local LCD_PADDING = 1

local LINE_LENGTH = max_chars
local NUMBER_OF_LINES = 4

local LINE_HEIGHT = 7
local LINE_SPACING = 1
local CHAR_WIDTH = 5

function textline:create_lines(text)
    local line_num = 1
    local tab = {}
    for line in string.gmatch(text, '([^|\n]+)') do
        table.insert(tab, line)
        line_num = line_num+1
        if line_num > NUMBER_OF_LINES then
            return tab
        end
    end
    return tab
end

function textline:generate_texture(lines)
    local texture = "[combine:"..LCD_WIDTH .."x"..LCD_HEIGHT
    local ypos = -2
    for i = 1, #lines do
        texture = texture..self:generate_line(lines[i], ypos)
        ypos = ypos + LINE_HEIGHT + LINE_SPACING
    end
    return texture
end

function textline:generate_line(s, ypos)
    local i = 1
    local parsed = {}
    local width = 0
    local chars = 0
    while chars < max_chars and i <= #s do
        local file = nil
        if charmap[s:sub(i, i)] ~= nil then
            file = charmap[s:sub(i, i)]
            i = i + 1
        elseif i < #s and charmap[s:sub(i, i + 1)] ~= nil then
            file = charmap[s:sub(i, i + 1)]
            i = i + 2
        else
            print("[textline] W: unknown symbol in '"..s.."' at "..i)
            i = i + 1
        end
        if file ~= nil then
            width = width + CHAR_WIDTH
            table.insert(parsed, file)
            chars = chars + 1
        end
    end
    width = width - 1

    local texture = ""
    local xpos = LCD_PADDING
    for i = 1, #parsed do
        texture = texture..":"..xpos..","..ypos.."="..parsed[i]..".png"
        xpos = xpos + CHAR_WIDTH + 1
    end
    return texture
end

minetest.register_craft({
    output = "textline:lcd 2",
    recipe = {
        {"default:steel_ingot", "digilines:wire_std_00000000", "default:steel_ingot"},
        {"mesecons_lightstone:lightstone_green_off","mesecons_lightstone:lightstone_green_off","default:glass"},
        {"default:glass","default:glass","default:glass"}
    }
})

minetest.register_craft({
    output = "textline:background 2",
    recipe = {
        {"default:steel_ingot", "default:glass", "default:steel_ingot"},
        {"mesecons_lightstone:lightstone_green_off","mesecons_lightstone:lightstone_green_off","default:glass"},
        {"default:glass","default:glass","default:glass"}
    }
})

minetest.register_craft({
	type = "shapeless",
	output = "textline:lcd",
	recipe = {"textline:hud"},
})

minetest.register_craft({
	type = "shapeless",
	output = "textline:hud",
	recipe = {"textline:lcd"},
})
