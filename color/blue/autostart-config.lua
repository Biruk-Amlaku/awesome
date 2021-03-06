-----------------------------------------------------------------------------------------------------------------------
--                                              Autostart app list                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local autostart = {}

-- Application list function
--------------------------------------------------------------------------------
function autostart.run()
    -- environment
    awful.spawn("pulseaudio --start")
    awful.spawn.with_shell("screenalign")
    awful.spawn("nm-applet")

    -- utils
    -- awful.spawn.with_shell("compton")
    awful.spawn("xautolock -time 5 -locker lock &")

    -- apps
    -- awful.spawn.with_shell("clipflap")
    -- awful.spawn.with_shell("transmission-gtk -m")
    -- awful.spawn.with_shell("pragha --toggle_view")
end

-- Read and commads from file and spawn them
--------------------------------------------------------------------------------
function autostart.run_from_file(file_)
    local f = io.open(file_)
    for line in f:lines() do
        if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
    end
    f:close()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
