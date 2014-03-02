-- Need
--      transset-df
--
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- https://github.com/copycat-killer/lain/wiki
local lain = require("lain")
markup     = lain.util.markup

-- theme
-- awful.util.spawn_with_shell("xfsettingsd")

-- vicious widgets library
local vicious = require("vicious")
-- local vicious = require("chocoplant")

local volume = require("volume")

-- default backlight
awful.util.spawn_with_shell("xbacklight -set 45")

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("nm-applet")
run_once("urxvtd")
run_once("dropboxd")
run_once("xscreensaver -no-splash")
run_once("xcompmgr -cF")
-- run_once("skype")
-- }}}

-- {{{ Font Setting -----------------------------------------------------------
awesome.font = "LiHei Pro 12"
-- }}} ------------------------------------------------------------------------

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- {{{ Themes Setting ---------------------------------------------------------
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")
-- }}} ------------------------------------------------------------------------

-- default terminal and editor
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
-- modkey
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    -- delete useless layouts
    awful.layout.suit.tile,               -- 1 (tile.right)
    awful.layout.suit.tile.left,          -- 2
    awful.layout.suit.tile.bottom,        -- 3
    -- awful.layout.suit.tile.top,           --
    -- awful.layout.suit.fair,               --
    -- awful.layout.suit.fair.horizontal,    --
    -- awful.layout.suit.spiral,             --
    -- awful.layout.suit.spiral.dwindle,     --
    awful.layout.suit.max,                -- 4
    -- awful.layout.suit.max.fullscreen,     --
    -- awful.layout.suit.magnifier,          --
    awful.layout.suit.floating            -- 5
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Each screen has its own tag table.
tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag(
        {"1", "2", "3", "4", "5", "6", "7", "8", "9"},
        s,
        { layouts[2], layouts[2], layouts[2],
          layouts[2], layouts[2], layouts[2],
          layouts[2], layouts[2], layouts[2]
        }
    )
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "Logout choose", 'lubuntu-logout'},
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

awful.menu.menu_keys = { up    = { "k", "Up" }, down  = { "j", "Down" },
                         enter = { "Right" }, back  = { "h", "Left" },
                         exec  = { "l", "Return", "Right" },
                         close = { "q", "Escape" },
                       }

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu,
                                        beautiful.awesome_icon },
                                    { "Terminal", terminal },
                                    { "Vim", "urxvt -e vim" },
                                    { "emcas", "urxvt -e emacs" },
                                    { "ranger", "urxvt -e ranger" },
                                    { "alsamixer", "urxvt -e alsamixer" },
                                    { "www", "chromium" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
-- Set the terminal for applications that require it
menubar.utils.terminal = terminal-- }}}
-- }}}

-- {{{ Wibox
-- return the command output for tooltips below
local function tooltip_func_text(command)
    local fd = io.popen(command)
    local lines = fd:read('*a')
    fd:close()
    -- return '<span color="#00FF00">' .. command .. ' :\n\n' .. lines .. '</span>'
    return command .. ' :\n\n' .. lines
end

-- network usage
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
                '<span color="#CC9090">⇩${enp2s0f0 down_kb}</span>' ..
                '<span color="#7F9F7F">⇧${enp2s0f0 up_kb}</span>', 3)

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
textclock = awful.widget.textclock(markup("#7788af", "%a %b %d") .. markup("#343639", ">") .. markup("#de5e1e", " %H:%M:%S "), 1)   -- 1 means update per 1 second
-- Calendar
lain.widgets.calendar:attach(textclock, { font_size = 10 })


-- CPU usage
cpuwidget = wibox.widget.textbox()
cpuwidget_t = awful.tooltip( {
    objects = {cpuwidget},
    timer_function = function ()
        return tooltip_func_text('top -b -n 1 | head -n 15')
    end
})
vicious.register(cpuwidget, vicious.widgets.cpu,
                 '<span color="#CC0000">$1% </span>[$2:$3:$4:$5]' , 5)

-- memory usage
memwidget = wibox.widget.textbox()
memwidget_t = awful.tooltip( {
    objects = {memwidget},
    timer_function = function ()
        return tooltip_func_text('free -h')
    end
})
vicious.register(memwidget, vicious.widgets.mem,
                 '<span color="#e0da37">$2MB/$3MB</span> (<span color="#00EE00">$1%</span>)', 5)

-- battery status
batwidget = wibox.widget.textbox()
batwidget_t = awful.tooltip( {
    objects = {batwidget},
    timer_function = function ()
        return tooltip_func_text('acpi -V')
    end
})
vicious.register(batwidget, vicious.widgets.bat, '$2% $3[$1]', 2, 'BAT1')
batwidget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function()
            naughty.notify( {title='Ouch!!',
                             text="you click me!",
                             timeout=10})
        end)
    )
)

-- temperature status
thermalwidget = wibox.widget.textbox()
thermalwidget_t = awful.tooltip( {
    objects = {thermalwidget},
    timer_function = function ()
        return tooltip_func_text('sensors')
    end
})
vicious.register(thermalwidget, vicious.widgets.thermal, " | CPU: $1°C | ", 10, { "coretemp.0", "core"} )

-- Coretemp
-- tempicon = wibox.widget.imagebox(beautiful.widget_temp)
-- tempwidget = lain.widgets.temp({
--     settings = function()
--         widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
--     end
-- })

-- Battery
-- baticon = wibox.widget.imagebox(beautiful.widget_batt)
-- batwidget = lain.widgets.bat({
--     settings = function()
--         if bat_now.perc == "N/A" then
--             bat_now.perc = "AC "
--         else
--             bat_now.perc = bat_now.perc .. "% "
--         end
--         widget:set_text(bat_now.perc)
--     end
-- })

-- -- Net
-- netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
-- --netdownicon.align = "middle"
-- netdowninfo = wibox.widget.textbox()
-- netupicon = wibox.widget.imagebox(beautiful.widget_netup)
-- --netupicon.align = "middle"
-- netupinfo = lain.widgets.net({
--     settings = function()
--         widget:set_markup(markup("#e54c62", net_now.sent .. " "))
--         netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
--     end
-- })

-- Cmus
cmuswidget = wibox.widget.textbox()
cmuswidget_t = awful.tooltip( {
    objects = {cmuswidget},
    timer_function = function ()
        return tooltip_func_text('cmus-remote -Q | head -2 | tail -1 | cut -b6-')
    end
})
vicious.register(cmuswidget, vicious.widgets.cmus, "$1")

-- register's 4th parameter is the update interval

-- widget separator
separator = wibox.widget.textbox()
separator:set_text(" | ")


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    -- left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()

    -- only display systray on screen 1
    if s == 1 then right_layout:add(wibox.widget.systray()) end

    -- add my widgets (on screen 2 when i use duel screen)
    if screen.count() == 2 then
        if s == 2 then
            right_layout:add(netwidget)
            right_layout:add(separator)
            right_layout:add(cpuwidget)
            right_layout:add(separator)
            right_layout:add(memwidget)
        end
    else
        right_layout:add(cmuswidget)
        right_layout:add(netwidget)
        right_layout:add(separator)
        right_layout:add(volume_widget)
        -- right_layout:add(volumewidget)
        right_layout:add(cpuwidget)
        right_layout:add(separator)
        right_layout:add(memwidget)
    end
    right_layout:add(separator)
    -- right_layout:add(tempwidget)
    right_layout:add(batwidget)
    right_layout:add(thermalwidget)
    right_layout:add(textclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "a",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "d",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- dynamic change transparency (need "transset-df")
    -- "Next" is PageDown, "Prior" is PageUp
    awful.key({ modkey }, "Prior", function (c) awful.util.spawn("transset-df --actual --dec 0.1") end),
    awful.key({ modkey }, "Next", function (c) awful.util.spawn("transset-df --actual --inc 0.1") end),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    -- awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    -- awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    -- spawn a new terminal
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- resize the client (on the focus)
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),

    -- what the fuck?
    -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),

    -- change window layouts
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- i can move and click my mouse with hotkeys!!
    awful.key({ modkey, "Shift"   }, "h", function () local mc = mouse.coords()
                mouse.coords({x = mc.x-15, y = mc.y}) end),
    awful.key({ modkey, "Shift"   }, "j", function () local mc = mouse.coords()
                mouse.coords({x = mc.x, y = mc.y+15}) end),
    awful.key({ modkey, "Shift"   }, "k", function () local mc = mouse.coords()
                mouse.coords({x = mc.x, y = mc.y-15}) end),
    awful.key({ modkey, "Shift"   }, "l", function () local mc = mouse.coords()
                mouse.coords({x = mc.x+15, y = mc.y}) end),
    awful.key({ modkey, "Shift"   }, "u", function () awful.util.spawn("xdotool click 1") end),
    awful.key({ modkey, "Shift"   }, "i", function () awful.util.spawn("xdotool click 3") end),

    -- restore the minimized client
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    -- run a piece of lua code
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- lock my screen
    awful.key({ modkey }, "F12", function () awful.util.spawn("xscreensaver-command -lock") end),

    -- shutter as printscreen tools    http://shutter-project.org/
    -- awful.key({ modkey }, "Print", function () awful.util.spawn("/opt/shutter/bin/shutter") end)
    awful.key({ }, "Print", function () awful.util.spawn("/usr/bin/gnome-screenshot -i") end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),


    -- volume (use fn key)
    -- https://bbs.archlinux.org/viewtopic.php?id=142272
    awful.key({ }, "#123", function () awful.util.spawn("amixer set Master 5%+") end),
    awful.key({ }, "#122", function () awful.util.spawn("amixer set Master 5%-") end),
    awful.key({'F8' }, "#121", function () awful.util.spawn("amixer sset Master toggle") end), -- Mute toggle

    --brightness (use fn key)
    awful.key({ }, "#232", function () awful.util.spawn("xbacklight -dec 10") end),
    awful.key({ }, "#233", function () awful.util.spawn("xbacklight -inc 10") end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ awful rules ------------------------------------------------------------

awful.rules.rules = {
    -- {
    --     rule = { class = "your-app-class-here" },
    --     properties = { floating = true
    --                    opacity = 0.8 },
    --     callback = function( c )
    --         c:geometry( { width = 200 , height = 800 } )
    --     end
    -- },

    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     size_hints_honor = false,  -- this will make window be full height
                     buttons = clientbuttons } },

    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "URxvt" },
      properties = { size_hints_honor = false } },
}
-- }}} ------------------------------------------------------------------------

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- opacity need Xcompmgr
-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus c.opacity = 1 end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal c.opacity = 0.9 end)
-- }}}

-- vim:set fdm=marker:
