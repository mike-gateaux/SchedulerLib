--!strict
--!optimize 2
--!native

local RunService = game:GetService("RunService")

local synchronize = task.synchronize
local desynchronize = task.desynchronize

local task = {}
local cch = {}

task.synchronize = synchronize
task.desynchronize = desynchronize

function wait(p)
	local waited = 0
	local last = workspace:GetServerTimeNow()

	repeat
		RunService.Heartbeat:Wait()
		waited += (workspace:GetServerTimeNow() - last)

		last = workspace:GetServerTimeNow()
	until waited >= p

	return waited
end

function task.wait(p)
	return wait(p)
end

function task.spawn(f, ...)
	return {pcall(coroutine.wrap, f, ...)}[2]
end

function task.delay(p, f, ...)
	local cancelled = false
	local args = {...}

	task.spawn(function()
		task.wait(p)

		if not cancelled then
			f(unpack(args))
			cancelled = true
		end
	end)

	return {
		cancel = function()
			cancelled = true
		end,
	}
end

function task.cancel(thread)
	thread.cancel()
end

function task.defer(f, ...)
	return task.spawn(pcall, f, ...)
end

return task
