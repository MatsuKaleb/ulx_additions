local MAX_CHUNK_SIZE = 32768
local requests = {}
local queue = {}

net.Receive("screen_victim", function(len)
    local quality = net.ReadUInt(8)
    local request = net.ReadUInt(8)

    hook.Add("PostRender", "PreventOverlay_" .. request, function()
        local data = render.Capture{
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            quality = quality
        }

        local chunk_count = math.ceil(string.len(data) / MAX_CHUNK_SIZE)

        for index = 1, chunk_count do
            local chunk_data = string.sub(data, (index - 1) * MAX_CHUNK_SIZE + 1, index * MAX_CHUNK_SIZE)
            local chunk_len = string.len(chunk_data)

            table.insert(queue, {
                chunk_data = chunk_data,
                chunk_len = chunk_len,
                chunk_count = chunk_count,
                request = request,
                index = index
            })

            timer.Start("screen_queue")
        end

        hook.Remove("PostRender", "PreventOverlay_" .. request)
    end)
end)

timer.Create("screen_queue", 0.5, 0, function()
    local data = table.remove(queue, 1)

    if not data then
        timer.Stop("screen_queue")

        return
    end

    net.Start("screen_victim")
        net.WriteData(data.chunk_data, data.chunk_len)
        net.WriteUInt(data.chunk_count, 8)
        net.WriteUInt(data.request, 8)
        net.WriteUInt(data.index, 8)
    net.SendToServer()
end)

net.Receive("screen_caller", function(len)
    local chunk_data = net.ReadData((len - 24) / 8)
    local chunk_count = net.ReadUInt(8)
    local request = net.ReadUInt(8)
    local index = net.ReadUInt(8)

    if not requests[request] then
        requests[request] = {}
    end

    ULib.console(nil, string.format("Client received chunk %i of %i for request #%i", index, chunk_count, request))
    requests[request][index] = chunk_data

    if #requests[request] == chunk_count then
        local data = table.concat(requests[request])

        local pnl = vgui.Create("DFrame")
        pnl:SetSize(ScrW() - 50, ScrH() - 50)
        pnl:SetPos(25, 25)
        pnl:MakePopup()
        pnl:SetTitle("Captured screen")
        pnl:SetSizable(true)

        local html = pnl:Add("HTML")
        html:SetHTML("<style type=\"text/css\"> body { margin: 0; padding: 0; overflow: hidden; } img { width: 100%; height: 100%; } </style> <img src=\"data:image/jpg;base64," .. util.Base64Encode(data) .. "\"> ")
        html:Dock(FILL)
    end
end)
