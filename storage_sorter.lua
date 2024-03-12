-- Storage sorter
-- version 1.0
-- 
-- THIS SCRIPT IS INTENDED TO BE INCLUDED INTO sorter_core.lua
-- By itself, it's useless
-- 
-- Insert this to the sorter_core to make it work as a controller for the storage sorting system.
-- Don't forget to include  sorter_functions.lua  to where it belongs
-- 
-- License: GNU AGPL https://www.gnu.org/licenses/agpl-3.0.en.html
-- Copyright Ghaydn (ghaydn@ya.ru), 2024
-- https://t.me/rhythmnation
-- 
-- https://github.com/Ghaydn/minetest_lw_sorter/

------------------------------------------------------------------------------------------------
----- INSERTS ----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- CHANNELS
-- Define output conduit channels here
local example = "foo"


------------------------------------------------------------------------------------------------

-- ITEM LISTS
-- Use these for sorting
-- Try to make each list smaller than the previous one to reduce luacontroller load.

-- simplest: just an item name
local send_by_name = {
	[example] = {
		"default:cobble",
	},
}

------------------------------------------------------------------------------------------------

-- a bit harder: by name beginning
local send_by_beginning = {
	[example] = {
		"defau",
	},
}

------------------------------------------------------------------------------------------------

-- beginning, but it is a modname. So that it will end with ":"
local send_by_modname = {
	[example] = {
		"default",
	},
}

------------------------------------------------------------------------------------------------

-- The most complicated, full featured search. Try to avoid this section if possible.
local send_by_search = {
	[default] = {
		"cobb",
	},
}

------------------------------------------------------------------------------------------------

--- THIS SCRIPT REQUIRES  search_functions.lua  INCLUDED HERE

------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
----- SORTING MECHANISM ------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- You won't need to modify this part


-- This is the function that makes all main search
local function get_item_direction(item_name)
	
	-- try to find by name
	for dir, list in pairs(send_by_name) do
		
		local address = array_find(list, item_name)
		if address then
			return dir
		end
	end
	
	-- try to find by beginning
	for dir, list in pairs(send_by_beginning) do
		for _, beginning in ipairs(list) do
			local address = string_begins(item_name, beginning)
			if address then
				return dir
			end
		end
	end
	
	-- try to find by modname
	for dir, list in pairs(send_by_modname) do
		for _, modname in ipairs(list) do
			local address = string_begins(item_name, modname)
			if address then
				return dir
			end
		end
	end
	
	
	-- try to find (slow)
	for dir, key in pairs(send_by_modname) do
		for _, modname in ipairs(key) do
			local address = string_begins(item_name, modname)
			if address then
				return dir
			end
		end
	end
	
		
	-- not found
	return default
	
end

------------------------------------------------------------------------------------------------

local function clear_memory()
	
	mem.var = {
		items = {},
		index = 0,
		idle_index = 0,
	}
	
end

------------------------------------------------------------------------------------------------

local function report(item, target)
	local text = ""
	
	if item ~= nil and target ~= nil then
		text = "Item " .. item .. " sent to " .. target .. "."
		if #mem.var.items == 0 then
			text = text .. " Empty."
		else
			text = text .. " Sending next."
		end
	else
		text = "Total items: " .. tostring(#mem.var.items)
	end
	
	digiline_send(lcd, text)
end
