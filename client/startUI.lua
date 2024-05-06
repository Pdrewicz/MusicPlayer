local url = "https://wd-eb.pdrewicz.site/musicplayer/client/"
local url2 = "https://wd-eb.pdrewicz.site/os/client/"

function downloadFile(fileUrl,fileName)
    local out = http.get(fileUrl)
    local content = nil
    if out then content = out.readAll() end
    if content then
        local file
        if arg[1] and arg[1] == "pd-os" then
            file = fs.open("programs/musicPlayer/"..fileName,"w")
        else
            file = fs.open(fileName,"w")
        end
        file.write(content)
        file.close()
    end
end

if not (arg[1] and arg[1] == "pd-os") then
    downloadFile(url2.."basalt.lua","basalt.lua")
end

local basalt = require("/basalt")

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

downloadFile(url.."json.lua","json.lua")

downloadFile(url.."musicPlayerUI.lua","musicPlayer.lua")

if arg[1] and arg[1] == "pd-os" then
    if not fs.exists("programs/musicPlayer/playlist.json") then
        local file = fs.open("programs/musicPlayer/playlist.json","w")
        file.close()
    end
else
    if not fs.exists("playlist.json") then
        local file = fs.open("playlist.json","w")
        file.close()
    end
end

downloadFile(url.."speaker4.lua","speaker4.lua")

downloadFile(url.."check.txt","check.txt")
local valid = false
if arg[1] and arg[1] == "pd-os" then
    if fs.exists("programs/musicPlayer/check.txt") then
        valid = true
        shell.run("rm","programs/musicPlayer/check.txt")
    end
else
    if fs.exists("check.txt") then
        valid = true
        shell.run("rm","check.txt")
    end
end

if valid then
    if arg[1] and arg[1] == "pd-os" then
        shell.openTab("programs/musicPlayer/musicPlayer.lua","pd-os")
    else
        shell.openTab("musicPlayer.lua")
    end
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