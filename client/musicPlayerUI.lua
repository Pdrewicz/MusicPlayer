local version = "0.8.2"
local updateLog = "Update v"..version..":\nI think I fixed this thing"
os.setComputerLabel("Music Player "..version)

local url1 = "https://musicplayer.pdrewicz.site/"
local url2 = "https://pdrewicz.site/musicplayer/"

local url = url1

shell.run("wget",url2.."startUI.lua","temp/start.lua")
if fs.exists("temp/start.lua") then
    shell.run("rm","startup.lua")
    shell.run("mv","temp/start.lua","startup.lua")
end

if fs.exists("json.lua") then
    os.loadAPI("json.lua")
else
    os.reboot()
end

local player = ""
local songName = ""
local songLink = ""
local playlist = {}

if fs.exists("name.txt") then
    local f = fs.open("name.txt","r")
    player = f.readLine()
    f.close()
else
    print("Enter Username:")
    player = read()
    
    local f = fs.open("name.txt","w")
    f.write(player)
    f.close()
end

http.post(url1.."createuser.php","player="..player)
http.post(url2.."adduser.php","player="..player)

local basalt = require("basalt")

local mainFrame = basalt.createFrame()
    :setBackground(colors.black)

local downloadThread = mainFrame:addThread()
local playlistThread = mainFrame:addThread()


----------- Main menu --------------------
local mainMenuFrame = mainFrame:addFrame()
    :setSize("{parent.w}", "{parent.h}")
    :setBackground(colors.black)
    :setVisible(false)

mainMenuFrame:addLabel()
    :setPosition(1,1)
    :setSize("{parent.w}",1)
    :setText("Logged as "..player)
    :setBackground(colors.black)
    :setForeground(colors.white)
mainMenuFrame:addLabel()
    :setPosition(7,4)
    :setSize(6,1)
    :setText("Music")
    :setBackground(colors.black)
    :setForeground(colors.white)
mainMenuFrame:addLabel()
    :setPosition(13,3)
    :setSize(8,3)
    :setText("")
    :setBackground(colors.orange)
    :setForeground(colors.black)
mainMenuFrame:addLabel()
    :setPosition(14,4)
    :setSize(6,1)
    :setText("Player")
    :setBackground(colors.orange)
    :setForeground(colors.black)
mainMenuFrame:addLabel()
    :setPosition(8,7)
    :setSize(15,1)
    :setText("By Pdrewicz")
    :setBackground(colors.black)
    :setForeground(colors.white)
mainMenuFrame:addButton()
    :setPosition(6,10)
    :setSize(15,3)
    :setText("Show songs")
    :setBackground(colors.cyan)
    :onClick(function()
        showSongs()
    end)
mainMenuFrame:addButton()
    :setSize(15,3)
    :setPosition(6,15)
    :setText("Add song")
    :setBackground(colors.cyan)
    :onClick(function()
        addSong()
end)
mainMenuFrame:addLabel()
    :setPosition(1,19)
    :setSize("{parent.w}",2)
    :setText(updateLog)
    :setBackground(colors.black)
    :setForeground(colors.white)

----------- Download -------------------
local downloadFrame = mainFrame:addFrame()
    :setSize("{parent.w}", "{parent.h}")
    :setBackground(colors.black)
    :setVisible(false)

local downloadLabel = downloadFrame:addLabel()
    :setPosition(6,5)
    :setSize(15,3)
    :setBackground(colors.cyan)
    :setText("")
    :setForeground(colors.black)

function downloadSong()
    local out = http.post(url.."filelist.php","player="..player).readAll()
    local songs = {}
    local separator = string.find(out,"<br>")
    if out and not separator then
        songs[1] = out
    end
    while separator do
        local song = string.sub(out,0,separator-1)
        out = string.sub(out,separator+4)
        separator = string.find(out,"<br>")
        songs[#songs+1] = song
    end

    if #songs < 10 then
        downloadLabel:setText("Downloading...")
        http.post(url.."index.php","name="..songName.."&link="..songLink.."&player="..player)

        local exists = "false"
        while exists == "false" do
            local out = http.post(url.."filelist.php","player="..player).readAll()
            local songs = {}
            local separator = string.find(out,"<br>")
            while separator do
                local song = string.sub(out,0,separator-1)
                out = string.sub(out,separator+4)
                separator = string.find(out,"<br>")
                songs[#songs+1] = song
            end
            for i,v in ipairs(songs) do
                if v == songName then exists = true end
            end
            downloadLabel:setText("Waiting for server...")
            sleep(0.5)
        end
        downloadLabel:setText("done")
        mainMenu()
    else
        term.setTextColor(colors.red)
        downloadLabel:setText("Too many songs")
        sleep(1)
        mainMenu()
    end
end

----------- Add song --------------------
local addSongFrame = mainFrame:addFrame()
    :setSize("{parent.w}", "{parent.h}")
    :setBackground(colors.black)
    :setVisible(false)

local songNameInput = addSongFrame:addInput()
    :setPosition(6,5)
    :setSize(15,3)
    :setBackground(colors.cyan)
    :setDefaultText("Song name:")
    :setForeground(colors.black)
local songLinkInput = addSongFrame:addInput()
    :setPosition(6,10)
    :setSize(15,3)
    :setBackground(colors.cyan)
    :setDefaultText("Youtube link:")
    :setForeground(colors.black)
addSongFrame:addButton()
    :setSize(15,3)
    :setPosition(6,15)
    :setText("Download")
    :setBackground(colors.cyan)
    :onClick(function()
        addSongFrame:hide()
        downloadFrame:show()
        songName = songNameInput:getValue()
        songName = string.gsub(songName, "%s+", "_")
        songLink = songLinkInput:getValue()
        downloadThread:start(downloadSong)
end)
addSongFrame:addButton()
    :setSize("{parent.w}", 1)
    :setPosition(1,"{parent.h - 2}")
    :setBackground(colors.red)
    :setForeground(colors.black)
    :setText("Back")
    :onClick(function()
        mainMenu()
    end)

----------- Show songs --------------------
local showSongsFrame = mainFrame:addFrame()
    :setSize("{parent.w}", "{parent.h}")
    :setBackground(colors.black)
    :setVisible(false)


function startBasalt()
    basalt.autoUpdate()
end

function checkUrl()
    shell.run("wget",url2.."check.txt","temp/check.txt")
    if fs.exists("temp/check.txt") then
        shell.run("rm","temp/check.txt")
        url = url2
    else
        url = url1
    end
end

function mainMenu()
    addSongFrame:hide()
    downloadFrame:hide()
    showSongsFrame:hide()
    mainMenuFrame:show()
end

function addSong()
    mainMenuFrame:hide()
    downloadFrame:hide()
    showSongsFrame:hide()
    addSongFrame:show()
end

local playlistButton
function startPlaylist()
    playlistButton:setText("Downloading...")
    local tempPlaylist = {}
    for i,v in ipairs(playlist) do
        tempPlaylist[i] = {name=v,url=url1.."users/"..player.."/"..v..".dfpwm"}
    end
    local file = fs.open("playlist.json","w")
    file.write(json.encodePretty(tempPlaylist))
    file.close()
    shell.openTab("speaker4","playlist")
    shell.switchTab(2)
    playlistButton:setText("Play playlist")
end

function showSongs()
    mainMenuFrame:hide()
    downloadFrame:hide()
    addSongFrame:hide()
    showSongsFrame:show()
    showSongsFrame:removeChildren()
    showSongsFrame:addButton()
        :setSize("{parent.w}", 1)
        :setPosition(1,"{parent.h - 2}")
        :setBackground(colors.red)
        :setForeground(colors.black)
        :setText("Back")
        :onClick(function()
            mainMenu()
        end)
    playlistButton = showSongsFrame:addButton()
        :setSize("{parent.w}", 1)
        :setPosition(1,"{parent.h - 3}")
        :setBackground(colors.orange)
        :setForeground(colors.black)
        :setText("Play playlist")
        :onClick(function()
            playlistThread:start(startPlaylist)
        end)
    playlistButton:hide()
    url = url1
    playlist = {}
    local out = http.post(url.."filelist.php","player="..player).readAll()
    local songs = {}
    local separator = string.find(out,"<br>")
    while separator do
        local song = string.sub(out,0,separator-1)
        out = string.sub(out,separator+4)
        separator = string.find(out,"<br>")
        songs[#songs+1] = song
    end
    term.setTextColor(colors.cyan)
    for i,v in ipairs(songs) do
        showSongsFrame:addButton()
            :setSize("{parent.width - 4}",1)
            :setText(i..": "..v)
            :setPosition(2,i)
            :setBackground(colors.cyan)
            :setForeground(colors.black)
            :onClick(function(self,event,button,x,y)
                shell.openTab("speaker4",url.."users/"..player.."/"..v..".dfpwm")
                shell.switchTab(2)
            end)
        showSongsFrame:addButton()
            :setSize(1,1)
            :setPosition(1,i)
            :setBackground(colors.red)
            :setForeground(colors.black)
            :setText("x")
            :onClick(function()
                http.post(url.."removefile.php","player="..player.."&name="..v..".dfpwm")
                showSongs()
            end)
        showSongsFrame:addButton()
            :setSize(1,1)
            :setPosition("{parent.w-2}",i)
            :setBackground(colors.orange)
            :setForeground(colors.red)
            :setText("\14")
            :onClick(function(self,event,button)
                local playlistId = -1
                for j=1, #playlist do
                    if playlist[j] == v then
                        playlistId = j
                    end
                end
                if playlistId == -1 then
                    playlist[#playlist+1] = v
                    self:setForeground(colors.green)
                    self:setText("\15")
                else
                    self:setForeground(colors.red)
                    self:setText("\14")
                    local tempList = {}
                    for j = 1, #playlist do
                        if j ~= playlistId then
                            tempList[#tempList+1] = playlist[j]
                        end
                    end
                    playlist = tempList
                end
                if #playlist > 1 then
                    playlistButton:show()
                else
                    playlistButton:hide()
                end
            end)
    end
end

mainMenu()

startBasalt()
