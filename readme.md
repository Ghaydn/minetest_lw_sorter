
# LW Sorters for Minetest

This is a set of scripts for mesecons_luacontroller to automate various sorting
tasks using lwcomponents:conduit.

## Usage

1. Build a sorting mechanism. Typical sorting mechanism look like this:

```
 H ccCcCcC
 V c V V V
LCcc H H H

H - chests
V - hoppers (LW)
C - named conduits
c - unnamed conduits
L - luacontroller
```
Top-left chest is input. A conduit under it is "sorter", other named conduits
are threated as outputs. You can also connect an LCD to this system to monitor
it's functioning.

2. Add sorter_core.lua into luacontroller.

3a. If you need a storage sorter - include storage_sorter.lua and search_functions.lua
as said in the comments in corresponding files.

3b. If you need to sort iron and coal to make steel and iron - include steel_maker.lua,
as said in the comments.

3c. For other custom sorting algorithms - rewrite
` local function get_item_direction(item_name)

4. Don't forget to modify head section according to your needs. You might want
to change switch pin, channel names, or interrupt intervals.

All details are explained in the comments in corresponding files.

## LICENSING AND COPYING

These scripts are distributed under GNU AGPL https://www.gnu.org/licenses/agpl-3.0.en.html
You are free to copy, use and modify these scripts under your needs.
All derivative works must share the same license.
You can NOT use these scripts in closed-source projects.

Copyright Ghaydn, 2024
ghaydn@ya.ru
https://t.me/rhythmnation

Feel free to text me if you have any questions about these scripts or generally
about Minetest scripting.
