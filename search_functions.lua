-- Storage sorter
-- version 1.0
-- 
-- THIS SCRIPT IS INTENDED TO BE A PART OF OTHER SCRIPTS
-- By itself, it's useless
-- 
-- This script provides functions that are not available in luacontrollers:
-- 
-- find substring in a string
-- find value in a indexed table
-- check if a string begins with a substring
-- check if this itemname belongs to a mod
--
-- License: GNU AGPL https://www.gnu.org/licenses/agpl-3.0.en.html
-- Copyright Ghaydn (ghaydn@ya.ru), 2024
-- https://t.me/rhythmnation
-- 
-- https://github.com/Ghaydn/minetest_lw_sorter/

------------------------------------------------------------------------------------------------
----- SEARCH FUNCTIONS -------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


-- Re-implementation of String.find
-- returns forst matching position; nil if pattern is not a substring of str
local function find(str, pattern)
    
    -- check length
    local pattern_len = pattern:len()
    local str_len = str:len()
    
    if str_len < pattern_len then return nil end
    
    local max_pos = str_len - pattern_len + 1
    
    -- searching here
    for pos = 1, max_pos do
        if str:sub(pos, pos + pattern_len) == pattern then return pos end
    end
    
    -- not found
    return nil

end

------------------------------------------------------------------------------------------------

-- search for the first exact matching value in a table that looks like an array
local function array_find(array, pattern)
	
	for i, v in ipairs(array) do
		
		if v == pattern then return i end
		
	end
	
	return nil
end

------------------------------------------------------------------------------------------------

-- check if this item name begins with a specific string
-- it's simpler than using find
local function string_begins(str, pattern)
	
	local length = pattern:len()
	
	local sub = str:sub(1, length)
	
	return (sub == pattern)
end

------------------------------------------------------------------------------------------------

-- check if this item name belongs to a specific mod
-- the same as string_begins, but automatically adds ":"
local function is_mod(str, modname)
    
    local modlength = modname:len() + 1
    
    local sub = str:sub(1, modlength)
    
    return (sub == modname..":")

end

