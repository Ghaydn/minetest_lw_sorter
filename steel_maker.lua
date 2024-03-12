-- Steel maker
-- version 1.0
-- 
-- THIS SCRIPT IS INTENDED TO BE INCLUDED INTO sorter_core.lua
-- By itself, it's useless
-- 
-- Insert this to the sorter_core to make it work as a controller for the steel making system.
-- It automatically sorts iron and coal, so that you will have equal parts of steel and iron
-- 
-- License: GNU AGPL https://www.gnu.org/licenses/agpl-3.0.en.html
-- Copyright Ghaydn (ghaydn@ya.ru), 2024
-- https://t.me/rhythmnation
-- 
-- https://github.com/Ghaydn/minetest_lw_sorter/

------------------------------------------------------------------------------------------------
----- INSERTS ----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- if true, will keep unprocessed ore lumps
local keep_ore = true

-- conduit channels
local misc = "misc"
local iron = "iron"
local steel = "steel"


------------------------------------------------------------------------------------------------
----- STEEL MAKER SORTING MECHANISM ------------------------------------------------------------
------------------------------------------------------------------------------------------------
--- You won't need to change the section below
-- Sorter callbacks

local function clear_memory()
	
	mem.var = {
		
		total = {
			iron_to_steel = 0,
			coal_to_steel = 0,
			iron_to_iron = 0,
			coal_to_raw = 0,
			iron_to_raw = 0,
			
			iron = 0,
			steel = 0,
			raw_iron = 0,
			coal = 0,
			
			other = 0,
		},
		
		items = {},
		index = 0,
		idle_index = 0,
	}
	

end

------------------------------------------------------------------------------------------------

local function get_item_direction(item)
	
	-- iron - make steel and iron
	if item == "default:iron_lump" then
		
		
		-- not enough iron
		if mem.var.total.iron < mem.var.total.steel and
		(mem.var.total.iron <= mem.var.total.raw_iron or not keep_ore)
		then
			
			-- count and send
			mem.var.total.iron = mem.var.total.iron + 1
			mem.var.total.iron_to_iron = mem.var.total.iron_to_iron + 1
			return iron
			
		-- not enough taw iron
		elseif keep_ore and
		mem.var.total.raw_iron < mem.var.total.steel and
		mem.var.total.raw_iron <= mem.var.total.iron
		then
		
			-- count and send
			mem.var.total.raw_iron = mem.var.total.raw_iron + 1
			mem.var.total.iron_to_raw = mem.var.total.iron_to_raw + 1
			return misc
			
		-- not enough steel
		else
		
			-- count and send
			mem.var.total.steel = mem.var.total.steel + 1
			mem.var.total.iron_to_steel = mem.var.total.iron_to_steel + 1
			return steel
			
		end
		
	
	-- coal - make steel and not make steel
	elseif item == "default:coal_lump" then
		
		-- sent some iron lumps to make steel, but did not send any coal
		if mem.var.total.iron_to_steel > mem.var.total.coal_to_steel * 3 then
			
			-- count and send
			mem.var.total.coal_to_steel = mem.var.total.coal_to_steel + 1
			mem.var.total.steel = mem.var.total.steel + 1
			return steel
			
		-- enough coal on steel - sending to the storage
		else
			
			-- count and send
			mem.var.total.coal_to_raw = mem.var.total.coal_to_raw + 1
			mem.var.total.coal = mem.var.total.coal + 1
			return misc
			
		end
	
	-- other items
	else
		mem.var.total.other = mem.var.total.other + 1
		return misc
	end
end

------------------------------------------------------------------------------------------------

local function report(item, target)
	local text =
	"iron: " .. tostring(mem.var.total.iron) .. ", " ..
	"steel: " .. tostring(mem.var.total.steel) .. ", " ..
	"raw: " .. tostring(mem.var.total.raw_iron) .. ", " ..
	"coal: " .. tostring(mem.var.total.coal) .. ", " ..
	"misc: " .. tostring(mem.var.total.other) .. "."
	
	
	if #mem.var.items == 0 then
		if mem.var.index == 0 then
			text = "Empty."
			mem.var.index = 1
		else
			mem.var.index = 0
		end
	end
	
	digiline_send(lcd, text)
end
