local version = "0.9"
local updateLog = "Update v"..version..":\nYou can now use other\npeople's songs"

if not arg[1] or not arg[1] == "pd-os" then
    os.setComputerLabel("Music Player "..version)
end

local url = "https://wd-eb.pdrewicz.site/musicplayer/server/"
local downloadUrl = "https://wd-eb.pdrewicz.site/musicplayer/client/"

local player = ""
local songName = ""
local songLink = ""
local playlist = {}

if arg[1] and arg[1] == "pd-os" then
    shell.run("wget",downloadUrl.."startUI.lua","programs/musicPlayer/temp/start.lua")
    if fs.exists("programs/musicPlayer/temp/start.lua") then
        shell.run("rm","programs/musicPlayer/startup.lua")
        shell.run("mv","programs/musicPlayer/temp/start.lua","programs/musicPlayer/startup.lua")
    end
    if fs.exists("programs/musicPlayer/json.lua") then
        os.loadAPI("programs/musicPlayer/json.lua")
    else
        os.reboot()
    end
    if fs.exists("programs/musicPlayer/name.txt") then
        local f = fs.open("programs/musicPlayer/name.txt","r")
        player = f.readLine()
        f.close()
    else
	shell.run("clear")
        print("Enter Username:")
        player = read()
        
        local f = fs.open("programs/musicPlayer/name.txt","w")
        f.write(player)
        f.close()
    end
else
    shell.run("wget",downloadUrl.."startUI.lua","temp/start.lua")
    if fs.exists("temp/start.lua") then
        shell.run("rm","startup.lua")
        shell.run("mv","temp/start.lua","startup.lua")
    end
    if fs.exists("json.lua") then
        os.loadAPI("json.lua")
    else
        os.reboot()
    end
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
end

http.post(url.."createuser.php","player="..player)

local basalt = require("/basalt")

local mainFrame = basalt.createFrame()
    :setBackground(colors.black)

local downloadThread = mainFrame:addThread()
local playlistThread = mainFrame:addThread()


----------- Main menu --------------------
local mainMenuFrame = mainFrame:addFrame()
    :setSize("{parent.w}", "{parent.h}")
    :setBackground(colors.black)
    :setVisible(false)

if arg[1] and arg[1] == "pd-os" then
mainMenuFrame:addButton()
    :setSize(3,1)
    :setPosition("{parent.w-4}",1)
    :setBackground(colors.red)
    :setForeground(colors.black)
    :setText("X")
    :onClick(function()
        os.reboot()
    end)
end

local userNameLabel = mainMenuFrame:addLabel()
    :setPosition(1,1)
    :setSize("{parent.w}",1)
    :setText("Logged as "..player)
    :setBackground(colors.black)
    :setForeground(colors.white)

if arg[1] and arg[1] == "pd-os" then userNameLabel:setPosition(1,2) end

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
    :setPosition(2,10)
    :setSize(15,3)
    :setText("Show my songs")
    :setBackground(colors.cyan)
    :onClick(function()
        showSongs()
    end)
mainMenuFrame:addButton()
    :setSize(15,3)
    :setPosition(2,14)
    :setText("Add a song")
    :setBackground(colors.cyan)
    :onClick(function()
        addSong()
end)
mainMenuFrame:addButton()
    :setSize(7,5)
    :setPosition(19,11)
    :setText("")
    :setBackground(colors.lightBlue)
    :onClick(function()
        allSongs(1)
end)
mainMenuFrame:addLabel()
    :setSize(7,5)
    :setPosition(19,11)
    :setText("\n See\n All\n Songs")
    :setBackground(colors.lightBlue)
    :setZ(10)
mainMenuFrame:addLabel()
    :setPosition(1,18)
    :setSize("{parent.w}",3)
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
    if string.len(songName) > 18 then
        downloadLabel:setText("Name too Long\nMax 18 characters")
        sleep(1)
        mainMenu()
        return
    end
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
        songNameInput:setValue("")
        songLinkInput:setValue("")
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
        if string.find(v,"/") then
            tempPlaylist[i] = {name=string.sub(v,string.find(v,"/")+1,string.len(v)),url=url.."users/"..v..".dfpwm"}
        else
            tempPlaylist[i] = {name=v,url=url.."users/"..player.."/"..v..".dfpwm"}
        end
    end
    local file
    if arg[1] and arg[1] == "pd-os" then
        file = fs.open("programs/musicPlayer/playlist.json","w")
    else
        file = fs.open("playlist.json","w")
    end
    file.write(json.encodePretty(tempPlaylist))
    file.close()
    if arg[1] and arg[1] == "pd-os" then
        shell.openTab("programs/musicPlayer/speaker4","playlist","pd-os")
    else
        shell.openTab("speaker4","playlist")
    end
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
                if arg[1] and arg[1] == "pd-os" then
                    shell.openTab("programs/musicPlayer/speaker4",url.."users/"..player.."/"..v..".dfpwm")
                else
                    shell.openTab("speaker4",url.."users/"..player.."/"..v..".dfpwm")
                end
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

-- All songs
function allSongs(page)
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
        :setPosition(1,"{parent.h - 4}")
        :setBackground(colors.orange)
        :setForeground(colors.black)
        :setText("Play playlist")
        :onClick(function()
            playlistThread:start(startPlaylist)
        end)
    playlistButton:hide()
    playlist = {}
    local out = http.get(url.."listAllFiles.php").readAll()
    local songs = {}
    local separator = string.find(out,"<br>")
    while separator do
        local song = string.sub(out,0,separator-1)
        out = string.sub(out,separator+4)
        separator = string.find(out,"<br>")
        local exists = false
        for i,v in ipairs(songs) do
            if string.sub(v,string.find(v,"/")+1,string.len(v)) == string.sub(song,string.find(song,"/")+1,string.len(song)) then exists = true end
        end
        if not exists then
            songs[#songs+1] = song
        end
    end
    local pages = 1
    if math.floor(#songs/18) == #songs/18 then
        pages = #songs / 18
    else
        pages = math.floor(#songs/18)+1
    end
    local previousPageButton = showSongsFrame:addButton()
        :setSize(5, 1)
        :setPosition(1,"{parent.h - 3}")
        :setBackground(colors.gray)
        :setForeground(colors.black)
        :setText("<")
    if page > 1 then
        previousPageButton:setBackground(colors.green)
        previousPageButton:onClick(function()
            allSongs(page-1)
        end)
    end
    local nextPageButton = showSongsFrame:addButton()
        :setSize(5, 1)
        :setPosition("{parent.w - 6}","{parent.h - 3}")
        :setBackground(colors.gray)
        :setForeground(colors.black)
        :setText(">")
    if page < pages then
        nextPageButton:setBackground(colors.green)
        nextPageButton:onClick(function()
            allSongs(page+1)
        end)
    end
    showSongsFrame:addLabel()
        :setSize("{parent.w - 10}", 1)
        :setPosition(6,"{parent.h - 3}")
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :setTextAlign("center")
        :setText(page.." / "..pages)
        :onClick(function()
            allSongs(page+1)
        end)
    for i,v in ipairs(songs) do
        if i > 18*(page-1) and i < 18*page then
        showSongsFrame:addButton()
            :setSize("{parent.width - 3}",1)
            :setText(i..": "..string.sub(v,string.find(v,"/")+1,string.len(v)))
            :setPosition(1,i-18*(page-1))
            :setBackground(colors.cyan)
            :setForeground(colors.black)
            :onClick(function(self,event,button,x,y)
                if arg[1] and arg[1] == "pd-os" then
                    shell.openTab("programs/musicPlayer/speaker4",url.."users/"..v..".dfpwm")
                else
                    shell.openTab("speaker4",url.."users/"..v..".dfpwm")
                end
                shell.switchTab(2)
            end)
        showSongsFrame:addButton()
            :setSize(1,1)
            :setPosition("{parent.w-2}",i-18*(page-1))
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
end

mainMenu()

startBasalt()
