-- LW Sorter
-- version 1.01
-- for use with lwcomponents:conduit
-- 
-- This is the core part. Every sorter must have this. See INSERTS to add proper sorting algorithm
--
-- License: GNU AGPL https://www.gnu.org/licenses/agpl-3.0.en.html
-- Copyright Ghaydn (ghaydn@ya.ru), 2024
-- https://t.me/rhythmnation
-- 
-- https://github.com/Ghaydn/minetest_lw_sorter/


------------------------------------------------------------------------------------------------
----- LUA SORTER HEAD --------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- switch is connected to this port
local switch_pin = "A"
local switch = pin[switch_pin:lower()]

-- iterrupt time between checks
local scan_interval = 5

-- interrupt time between sending items
local sort_interval = 0.2

-- interrupt time when turned off
local idle_interval = 3

-- channel name for the LCD. Used to print status messaged.
local lcd = "lcd"

-- if this is true, then memory will be reset every time when sorter is programmes
-- and every time when switch is turned on
-- if mem.var == nil, then it will be reset anyway
local clear_memory_on_startup = true

-- if true, then, if more than one stack of items is available, these stacks will be processed
-- by one item from each stack; otherwise next stack won't be processed until current is finished
local parallel = true

-- This conduit will do the job
local sorter_channel = "sorter"

-- default conduit to which items will be sent if there will be no other option
local default = "misc"

------------------------------------------------------------------------------------------------
----- INSERTS ----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- Basic declarations:
-- You probably would want to define more conduit channels here

-- Also, additional pins/ports should be defined here

-- Any other variables and constants should be defined here too,
-- like item lists for the sorter

------------------------------------------------------------------------------------------------

-- if you need search functions - include search_functions.lua here

------------------------------------------------------------------------------------------------

-- Last, but not least:
-- In order to make this sorter work, you must define callback functions:

-- This is the function, that tells, which item should go where
-- it takes string item_name (modname:itemname) and returns conduit channel
-- return nil if item must kept inside
local function get_item_direction(item_name)
	return default
end

------------------------------------------------------------------------------------------------

-- This function defines initial memory.
-- Whatever you do here, you should keep mem.var.items table and index number
local function clear_memory()
	mem.var = {
		items = {},
		index = 0,
		idle_index = 0,
	}
end

------------------------------------------------------------------------------------------------

-- This function is called right after sending an item
-- Overwrite it to see whatever data you need
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

------------------------------------------------------------------------------------------------
----- LUA SORTER CORE --------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- All things below are the same in all types of sorters

-- shows report when controller is turned off
local function idle()

	-- cancel if turned on
	if switch then return end
	
	if mem.var.idle_index == 0 then
		digiline_send(lcd, "Turned off")
		mem.var.idle_index = 1
	else
		report()
		mem.var.idle_index = 0
	end
	
	interrupt(idle_interval, "idle")

end


------------------------------------------------------------------------------------------------

-- send scan message
local function scanning()
	
	-- cancel if turned off
	if not switch then return end
	
	-- no need to rescan if we have items left
	if #mem.var.items > 0 then
		interrupt(sort_interval, "sort")
		return
	end
	
	-- rescan
	digiline_send(sorter_channel, "inventory")
	
	-- await next rescan
	interrupt(scan_interval, "scan")
	
end

------------------------------------------------------------------------------------------------

-- send sort message
local function sorting()
	
	-- cancel if turned off
	if not switch then return end
	
	local slot = #mem.var.items
	
	-- check if tnere are items to sort
	if slot == 0 then
		interrupt(sort_interval, "scan")
		return
	end
	
	-- have items - doing sort
	
	-- selecting stack
	local index = slot
	if parallel then
		mem.var.index = (mem.var.index + 1) % slot
		index = mem.var.index + 1
	end
	
	-- take last item, remove it from the table
	local item = mem.var.items[index].name
	
	-- get best sort direction
	local address = get_item_direction(item)
	if address ~= nil then
		
		-- take item and send it somewhere
		local count = mem.var.items[index].count - 1
		mem.var.items[index].count = count
		if count == 0 then
			table.remove(mem.var.items, index)
		end
		
		-- send somewhere
		digiline_send(sorter_channel, {
			action = "transfer",
			target = address,
			item = item,
		})
		
		-- report
		report(item, target)
	end
	
	-- rescan or keep sorting
	if slot == 0 then
		interrupt(sort_interval, "scan")
	else
		interrupt(sort_interval, "sort")
	end
end

------------------------------------------------------------------------------------------------

local function set_inventory(inventory)
	
	mem.var.items = {}
	
	-- copy message information
	for _, item in ipairs(inventory) do
		if item.count > 0 then
			local tbl = {}
			for i, v in pairs(item) do
				tbl[i] = v
			end
			table.insert(mem.var.items, tbl)
		end
	end
	
	if #mem.var.items == 0 then
		report()
		interrupt(scan_interval, "scan")
	else
		interrupt(sort_interval, "sort")
	end
	
end

------------------------------------------------------------------------------------------------
----- DIGILINE EVENTS --------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- first start
if event.type == "program" then
	if clear_memory_on_startup or mem.var == nil then
		clear_memory()
	end
	digiline_send(lcd, "Sorter ready")
	if switch then
		interrupt(1, "scan")
	else
		interrupt(1, "idle")
	end
	
end

------------------------------------------------------------------------------------------------

-- interrupt
if event.type == "interrupt" then
	if event.iid == "scan" then
		scanning()
	elseif event.iid == "sort" then
		sorting()
	elseif event.iid == "idle" then
		idle()
	end
end

------------------------------------------------------------------------------------------------

-- switch
if event.type == "on" then
	if event.pin.name == switch_pin then
		if clear_memory_on_startup or mem.var == nil then
			clear_memory()
		end
		digiline_send(lcd, "Turning on...")
		interrupt(1, "scan")
	end
end

------------------------------------------------------------------------------------------------

-- switch
if event.type == "off" then
	if event.pin.name == switch_pin then
		digiline_send(lcd, "Turned off")
		mem.var.idle_index = 0
		idle()
	end
end

------------------------------------------------------------------------------------------------


if event.type == "digiline" and event.channel == sorter_channel and event.msg.action == "inventory" then
	
	set_inventory(event.msg.inventory)
	
end

