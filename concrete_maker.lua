-- Concrete maker
-- version 1.0
-- 
-- THIS SCRIPT IS INTENDED TO BE INCLUDED INTO sorter_core.lua
-- By itself, it's useless
-- 
-- Insert this to the sorter_core to make it work as a controller for the concrete making system
-- in techage.
-- Recipe: 2 steel ingots, 3 iron ingots, 20 gravel, 25 sand. This will give you 60 concrete.
-- 
-- License: GNU AGPL https://www.gnu.org/licenses/agpl-3.0.en.html
-- Copyright Ghaydn (ghaydn@ya.ru), 2024
-- https://t.me/rhythmnation
-- 
-- https://github.com/Ghaydn/minetest_lw_sorter/

------------------------------------------------------------------------------------------------
----- INSERTS ----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


-- default conduit to which items will be sent if there will be no other option
local default = "to_grate"


local grate = "to_grate"
local cement = "to_cement"
local wet = "to_wet_cement"
local concrete = "to_concrete"

local recipe = {
	{ item = "techage:iron_ingot", count = 3, target = grate },
	{ item = "default:steel_ingot", count = 2, target = grate },
	{ item = "default:sand", count = 5, target = cement },
	{ item = "default:sand", count = 15, target = wet },
	{ item = "default:sand", count = 5, target = concrete },
	{ item = "default:gravel", count = 15, target = wet },
	{ item = "default:gravel", count = 5, target = concrete },
}

local totals = {
	["techage:iron_ingot"] = 3,
	["default:steel_ingot"] = 2,
	["default:sand"] = 25,
	["default:gravel"] = 20,
}


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

--- check if we have enough items to work with
local function is_enough()
	
	-- creating summary
	local counts = {
		["techage:iron_ingot"] = 0,
		["default:steel_ingot"] = 0,
		["default:sand"] = 0,
		["default:gravel"] = 0,
	}
	
	-- counting
	for _, v in ipairs(mem.var.items) do
		
		for item, w in pairs(counts) do
			if v.name == item then
				counts[item] = w + v.count
				break
			end
		end
	end
	
	-- checking
	for i, v in pairs(totals) do
		if counts[i] < v then return false end
	end
	
	-- all counts are larger than the recipe
	return true
end

------------------------------------------------------------------------------------------------

local function get_item_direction(item_name)
	
	-- sort incorrect items
	if not (
		item_name == "techage:iron_ingot" or
		item_name == "default:steel_ingot" or
		item_name == "default:sand" or
		item_name == "default:gravel"
	)
	then
		return default
	end
	
	-- wait to get enough items
	if mem.var.recipe_index == 0 then
		if not is_enough() then
		-- rescan immediately
		digiline_send(sorter_channel, "inventory")
		return nil
		end
		
		mem.var.recipe_index = 1
	end
	
	local index = mem.var.recipe_index
	
	-- skipping wrong item
	if item_name ~= recipe[index].item then return nil end
	-- counting
	mem.var.recipe[index] = mem.var.recipe[index] + 1
	
	-- done with this item, going to next
	if mem.var.recipe[index] == recipe[index].count then
		mem.var.recipe_index = index + 1
		
		-- return to starting position
		if mem.var.recipe_index > #recipe then
			mem.var.recipe_index = 0
			mem.var.total_concrete = mem.var.total_concrete + 60
			mem.var.recipe = {0, 0, 0, 0, 0, 0, 0}
		end
		
	end
	
	--
	return recipe[index].target
	
end

------------------------------------------------------------------------------------------------

-- This function defines initial memory.
-- Whatever you do here, you should keep mem.var.items table and index number
local function clear_memory()
	mem.var = {
		items = {},
		index = 0,
		idle_index = 0,
		
		recipe = {0, 0, 0, 0, 0, 0, 0},
		recipe_index = 0,
		total_concrete = 0,
	}
end

------------------------------------------------------------------------------------------------

-- This function is called right after sending an item
-- Overwrite it to see whatever data you need
local function report(item, target)
	local text = "recipe: "
	
	for _, v in ipairs(mem.var.recipe) do
		text = text .. tostring(v) .. ", "
	end
	
	text = text .. "Total: " .. tostring(mem.var.total_concrete)
	
	if #mem.var.items == 0 then
		text = text .. ". Empty."
	end
	
	digiline_send(lcd, text)
end
