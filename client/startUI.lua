shell.run("wget", "run", "https://basalt.madefor.cc/install.lua", "release", "latest.lua")

local basalt = require("basalt")

local mainFrame = basalt.createFrame()
    :setBackground(colors.black)

mainFrame:addLabel()
    :setText("Loading...")
    :setTextAlign("center")
    :setPosition(1,4)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setFontSize(2)
    :setSize("{parent.w}",3)

function startBasalt()
    basalt.autoUpdate()
end

function start()
local url = "http://musicplayer.pdrewicz.site/client/"

shell.run("wget",url.."json.lua")

shell.run("mkdir","temp")
shell.run("wget",url.."/musicPlayerUI.lua","temp/musicPlayer.lua")
if fs.exists("temp/musicPlayer.lua") then
    shell.run("rm","musicPlayer.lua")
    shell.run("move","temp/musicPlayer.lua","musicPlayer.lua")
end

if not fs.exists("playlist.json") then
    local file = fs.open("playlist.json","w")
    file.close()
end

shell.run("wget",url.."speaker4.lua","temp/speaker4.lua")
if fs.exists("temp/speaker4.lua") then
    shell.run("rm","speaker4.lua")
    shell.run("move","temp/speaker4.lua","speaker4.lua")
end

shell.run("wget",url.."check.txt","temp/check.txt")
if fs.exists("temp/check.txt") then
    shell.run("rm","temp/check.txt")
    shell.openTab("musicPlayer.lua")
    shell.exit()
else
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.cyan)
    print("Server currently unavailable")
    sleep(1)
    shell.exit()
end
end

parallel.waitForAny(startBasalt,start)