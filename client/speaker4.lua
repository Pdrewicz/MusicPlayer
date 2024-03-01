-- SPDX-FileCopyrightText: 2021 The CC: Tweaked Developers
--
-- SPDX-License-Identifier: MPL-2.0
local file = arg[1]

a = true
local url = "https://musicplayer.pdrewicz.site/"
local volume = 100
local basalt = require("/basalt")
os.loadAPI("json.lua")

local songs = {}
local songId = 1

local mainFrame = basalt.createFrame()
    :setBackground(colors.black)

local thread = mainFrame:addThread()
local changeTimeThread = mainFrame:addThread()

function exit()
    speaker.stop()
    a = false
end

mainFrame:addButton()
    :setPosition("{parent.w/2-5}",10)
    :setSize(10,3)
    :setText("Stop")
    :setBackground(colors.red)
    :setForeground(colors.black)
    :onClick(function(self,event,button,x,y)
        thread:start(exit)
    end)

local realPlayActive = false
local realPlayArgs = {}
local currentTime = 0

mainFrame:addButton()
    :setPosition("{parent.w/2-3}",6)
    :setSize(6,3)
    :setText("\16\143")
    :setBackground(colors.orange)
    :setForeground(colors.black)
    :onClick(function(self,event,button,x,y)
        if realPlayActive then
            if file == "playlist" then
                songs[songId].args[6] = currentTime - 1
            else
                realPlayArgs[6] = currentTime - 1
            end
            realPlayActive = false
            speaker.stop()
        else
            changeTimeThread:start(changeTime)
        end
    end)


local timeDisplay = mainFrame:addFrame()
    :setBackground(colors.gray)
    :setPosition(2,14)
    :setSize(24,2)

local timeDisplayBar = timeDisplay:addFrame()
    :setBackground(colors.green)
    :setPosition(1,1)
    :setSize(1,2)
    :setZ(1)

local timeLabel = timeDisplay:addLabel()
    :setPosition("{parent.w/2-5}",1)
    :setSize(10,3)
    :setText("0/0")
    :setForeground(colors.black)
    :setZ(999)
    :setTextAlign("center")

local slider = mainFrame:addSlider()
    :setPosition(2,14)
    :setSize(24,2)
    :setBarType("horizontal")
    :setMaxValue(1)
    :setIndex(1)
    
slider:onChange(function(self, event, value)
    if file == "playlist" then
        songs[songId].args[6] = math.floor(value)
    else
        realPlayArgs[6] = math.floor(value)
    end
    changeTimeThread:start(changeTime)
end)

mainFrame:addLabel()
    :setBackground(colors.cyan)
    :setPosition("{parent.w/2-5}",17)
    :setSize(10,2)
    :setText("Volume")
    :setTextAlign("center")

local volumeDisplay = mainFrame:addFrame()
    :setBackground(colors.gray)
    :setPosition(2,18)
    :setSize(24,2)

local volumeDisplayBar = volumeDisplay:addFrame()
    :setBackground(colors.cyan)
    :setPosition(1,1)
    :setSize(24,2)
    :setZ(1)

local volumeLabel = volumeDisplay:addLabel()
    :setPosition("{parent.w/2-5}",1)
    :setSize(10,3)
    :setText("\n100%")
    :setForeground(colors.black)
    :setZ(999)
    :setTextAlign("center")

local volumeSlider = mainFrame:addSlider()
    :setPosition(2,18)
    :setSize(24,2)
    :setBarType("horizontal")
    :setMaxValue(1)
    :setIndex(1)
    
volumeSlider:onChange(function(self, event, value)
    volume = value * 100
    volumeLabel:setText("\n"..math.floor(volume).."%")
    volumeDisplayBar:setSize(math.floor(24*(value)),2)
    if realPlayActive then
        if file == "playlist" then
            songs[songId].args[6] = currentTime - 1
        else
            realPlayArgs[6] = currentTime - 1
        end
        realPlayActive = false
        speaker.stop()
        changeTimeThread:start(changeTime)
    end
end)
local songNameLabel
if file == "playlist" then
    songNameLabel = mainFrame:addLabel()
        :setPosition("{parent.w/2-10}",3)
        :setSize(20,3)
        :setText("\nLoading...")
        :setTextAlign("center")
        :setBackground(colors.gray)
        :setForeground(colors.white)
end

if file == "playlist" then
mainFrame:addButton()
    :setPosition("{parent.w/2-7}",6)
    :setSize(3,3)
    :setText(" \171")
    :setBackground(colors.orange)
    :setForeground(colors.black)
    :onClick(function(self,event,button,x,y)
        songId = songId - 1
        if songId < 1 then songId = #songs end
        songs[songId].args[6] = 1
        realPlayActive = false
        speaker.stop()
        changeTimeThread:start(changeTime)
    end)
mainFrame:addButton()
    :setPosition("{parent.w/2+4}",6)
    :setSize(3,3)
    :setText(" \187")
    :setBackground(colors.orange)
    :setForeground(colors.black)
    :onClick(function(self,event,button,x,y)
        songId = songId + 1
        if songId > #songs then songId = 1 end
        songs[songId].args[6] = 1
        realPlayActive = false
        speaker.stop()
        changeTimeThread:start(changeTime)
    end)
end

function startBasalt()
    basalt.autoUpdate()
end


function realPlay()
    chunks = realPlayArgs[1]
    start = realPlayArgs[2]
    size = realPlayArgs[3]
    speaker = realPlayArgs[4]
    decoder = realPlayArgs[5]
    time = realPlayArgs[6]
    slider:setMaxValue(#chunks)
    for i = time, #chunks do
        timeLabel:setText("\n"..i.." / "..#chunks)
        timeDisplayBar:setSize(math.floor(24*(i/#chunks)),2)
        currentTime = i
        local chunk = chunks[i]
        if not chunk then break end
        if start then
            chunk,start = start .. chunk, nil
            size = size + 4
        end
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer,volume/100) do
            os.pullEvent("speaker_audio_empty")
        end
    end
    term.exit()
end

function realPlayPlaylist()
    local song = songs[songId]
    name = song.name
    songNameLabel:show()
    songNameLabel:setText("\n"..name)
    chunks = song.args[1]
    start = song.args[2]
    size = song.args[3]
    speaker = song.args[4]
    decoder = song.args[5]
    time = song.args[6]
    slider:setMaxValue(#chunks)
    for i = time, #chunks do
        timeLabel:setText("\n"..i.." / "..#chunks)
        timeDisplayBar:setSize(math.floor(24*(i/#chunks)),2)
        currentTime = i
        local chunk = chunks[i]
        if not chunk then break end
        if start then
            chunk,start = start .. chunk, nil
            size = size + 4
        end
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer,volume/100) do
            os.pullEvent("speaker_audio_empty")
        end
    end
    songId = songId + 1
    if songId > #songs then songId = 1 end
    songs[songId].args[6] = 1
    realPlayActive = false
    speaker.stop()
    changeTimeThread:start(changeTime)
end

function realPlayLoop()
    while realPlayActive do
        sleep()
    end
end

function changeTime()
    realPlayActive = false
    speaker.stop()
    sleep(0.1)
    realPlayActive = true
    if file == "playlist" then
        parallel.waitForAny(realPlayLoop,realPlayPlaylist)
    else
        parallel.waitForAny(realPlayLoop,realPlay)
    end
end


local function get_speakers(name)
    if name then
        local speaker = peripheral.wrap(name)
        if speaker == nil then
            error(("Speaker %q does not exist"):format(name), 0)
            return
        elseif not peripheral.hasType(name, "speaker") then
            error(("%q is not a speaker"):format(name), 0)
        end

        return { speaker }
    else
        local speakers = { peripheral.find("speaker") }
        if #speakers == 0 then
            error("No speakers attached", 0)
        end
        return speakers
    end
end

local function pcm_decoder(chunk)
    local buffer = {}
    for i = 1, #chunk do
        buffer[i] = chunk:byte(i) - 128
    end
    return buffer
end

local function report_invalid_format(format)
    printError(("speaker cannot play %s files."):format(format))
    local pp = require "cc.pretty"
    pp.print("Run '" .. pp.text("help speaker", colours.lightGrey) .. "' for information on supported formats.")
end

function play()
    local speaker = get_speakers(name)[1]

    local handle, err
    local test2
    if http and file:match("^https?://") then
        print("Downloading...")
        handle, err = http.get{ url = file, binary = true }
        song = http.get{ url = file, binary = true }
    else
        handle, err = fs.open(file, "rb")
    end
    if not handle then
        printError("Could not play audio:")
        error(err, 0)
    end
    local start = handle.read(4)
    local pcm = false
    local size = 16 * 1024 - 4
    local valid = true
    local chunks = {}
    while valid do
        local temp = song.read(size)
        if temp then
            chunks[#chunks + 1] = temp
        else
            valid = false
        end
    end
    if start == "RIFF" then
        handle.read(4)
        if handle.read(8) ~= "WAVEfmt " then
            handle.close()
            error("Could not play audio: Unsupported WAV file", 0)
        end
        local fmtsize = ("<I4"):unpack(handle.read(4))
        local fmt = handle.read(fmtsize)
        local format, channels, rate, _, _, bits = ("<I2I2I4I4I2I2"):unpack(fmt)
        if not ((format == 1 and bits == 8) or (format == 0xFFFE and bits == 1)) then
            handle.close()
            error("Could not play audio: Unsupported WAV file", 0)
        end
        if channels ~= 1 or rate ~= 48000 then
            print("Warning: Only 48 kHz mono WAV files are supported. This file may not play correctly.")
        end
        if format == 0xFFFE then
            local guid = fmt:sub(25)
            if guid ~= "\x3A\xC1\xFA\x38\x81\x1D\x43\x61\xA4\x0D\xCE\x53\xCA\x60\x7C\xD1" then -- DFPWM format GUID
                handle.close()
                error("Could not play audio: Unsupported WAV file", 0)
            end
            size = size + 4
        else
            pcm = true
            size = 16 * 1024 * 8
        end
        repeat
            local chunk = handle.read(4)
            if chunk == nil then
                handle.close()
                error("Could not play audio: Invalid WAV file", 0)
            elseif chunk ~= "data" then -- Ignore extra chunks
                local size = ("<I4"):unpack(handle.read(4))
                handle.read(size)
            end
        until chunk == "data"
        handle.read(4)
        start = nil
    -- Detect several other common audio files.
    elseif start == "OggS" then return report_invalid_format("Ogg")
    elseif start == "fLaC" then return report_invalid_format("FLAC")
    elseif start:sub(1, 3) == "ID3" then return report_invalid_format("MP3")
    elseif start == "<!DO" --[[<!DOCTYPE]] then return report_invalid_format("HTML")
    end
    local decoder = pcm and pcm_decoder or require "cc.audio.dfpwm".make_decoder()
    realPlayArgs = {chunks,start,size,speaker,decoder,1}
    realPlayActive = true
    parallel.waitForAny(realPlayLoop,realPlay)

    --while true do
    --    local chunk = handle.read(size)
    --    if not chunk then break end
    --    if start then
    --        chunk, start = start .. chunk, nil
    --        size = size + 4
    --    end
    --    local buffer = decoder(chunk)
    --    while not speaker.playAudio(buffer) do
    --        os.pullEvent("speaker_audio_empty")
    --    end
    --end
    handle.close()
end

function playlist()
    local speaker = get_speakers(name)[1]
    local jsonIn
    if arg[2] and arg[2] == "aof-os" then
        jsonIn = json.decodeFromFile("programs/musicPlayer/playlist.json")
    else
        jsonIn = json.decodeFromFile("playlist.json")
    end
    
    for i,v in ipairs(jsonIn) do
    local handle, err
    local test2
    if http and v.url:match("^https?://") then
        print("Downloading...")
        handle, err = http.get{ url = v.url, binary = true }
        song = http.get{ url = v.url, binary = true }
    else
        handle, err = fs.open(v.url, "rb")
    end
    if not handle then
        printError("Could not play audio:")
        error(err, 0)
    end
    local start = handle.read(4)
    local pcm = false
    local size = 16 * 1024 - 4
    local valid = true
    local chunks = {}
    while valid do
        local temp = song.read(size)
        if temp then
            chunks[#chunks + 1] = temp
        else
            valid = false
        end
    end
    if start == "RIFF" then
        handle.read(4)
        if handle.read(8) ~= "WAVEfmt " then
            handle.close()
            error("Could not play audio: Unsupported WAV file", 0)
        end
        local fmtsize = ("<I4"):unpack(handle.read(4))
        local fmt = handle.read(fmtsize)
        local format, channels, rate, _, _, bits = ("<I2I2I4I4I2I2"):unpack(fmt)
        if not ((format == 1 and bits == 8) or (format == 0xFFFE and bits == 1)) then
            handle.close()
            error("Could not play audio: Unsupported WAV file", 0)
        end
        if channels ~= 1 or rate ~= 48000 then
            print("Warning: Only 48 kHz mono WAV files are supported. This file may not play correctly.")
        end
        if format == 0xFFFE then
            local guid = fmt:sub(25)
            if guid ~= "\x3A\xC1\xFA\x38\x81\x1D\x43\x61\xA4\x0D\xCE\x53\xCA\x60\x7C\xD1" then -- DFPWM format GUID
                handle.close()
                error("Could not play audio: Unsupported WAV file", 0)
            end
            size = size + 4
        else
            pcm = true
            size = 16 * 1024 * 8
        end
        repeat
            local chunk = handle.read(4)
            if chunk == nil then
                handle.close()
                error("Could not play audio: Invalid WAV file", 0)
            elseif chunk ~= "data" then -- Ignore extra chunks
                local size = ("<I4"):unpack(handle.read(4))
                handle.read(size)
            end
        until chunk == "data"
        handle.read(4)
        start = nil
    -- Detect several other common audio files.
    elseif start == "OggS" then return report_invalid_format("Ogg")
    elseif start == "fLaC" then return report_invalid_format("FLAC")
    elseif start:sub(1, 3) == "ID3" then return report_invalid_format("MP3")
    elseif start == "<!DO" --[[<!DOCTYPE]] then return report_invalid_format("HTML")
    end
    print("Playing " .. file)
    local decoder = pcm and pcm_decoder or require "cc.audio.dfpwm".make_decoder()
    local args = {chunks,start,size,speaker,decoder,1}

    songs[#songs+1] = {name = v.name,url = v.url,args = args}

    end
    http.get(url.."cleardrive.php")
    realPlayActive = true
    parallel.waitForAny(realPlayLoop,realPlayPlaylist)
end

function loop()
    while a do
        sleep()
    end
end

function main()
    if file == "playlist" then
        playlist()
    else
        play()
    end
    while true do
        sleep()
    end
end

parallel.waitForAny(startBasalt,main,loop)