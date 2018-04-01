util.AddNetworkString("screen_victim")
util.AddNetworkString("screen_caller")
local requests = {}
local queue = {}

function ScreenCapture(caller, victim, quality)
	local request = table.insert(requests, {
		caller = caller,
		victim = victim
	})

	net.Start("screen_victim")
		net.WriteUInt(quality, 8)
		net.WriteUInt(request, 8)
	net.Send(victim)
end

net.Receive("screen_victim", function(len, ply)
	local chunk_len = (len - 24) / 8
	local chunk_data = net.ReadData(chunk_len)
	local chunk_count = net.ReadUInt(8)
	local request = net.ReadUInt(8)
	local index = net.ReadUInt(8)

	if requests[request] then
		local caller = requests[request].caller
		local victim = requests[request].victim

		if IsValid(caller) and IsValid(victim) then
			if victim ~= ply then return end

			table.insert(queue, {
				chunk_data = chunk_data,
				chunk_len = chunk_len,
				chunk_count = chunk_count,
				request = request,
				index = index,
				caller = caller
			})

			timer.Start("screen_queue")
			ULib.console(caller, string.format("Server received chunk %i of %i for request #%i", index, chunk_count, request))
		end
	end
end)

timer.Create("screen_queue", 0.5, 0, function()
	local data = table.remove(queue, 1)

	if not data then
		timer.Stop("screen_queue")

		return
	end

	net.Start("screen_caller")
		net.WriteData(data.chunk_data, data.chunk_len)
		net.WriteUInt(data.chunk_count, 8)
		net.WriteUInt(data.request, 8)
		net.WriteUInt(data.index, 8)
	net.Send(data.caller)
end)
