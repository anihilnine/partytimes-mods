local modPath = '/mods/idleEngineers/'

local WAIT_SECONDS = 0.1
local current_tick = 0
local watch_tick = nil
local listeners = {}

local mThread = nil

local mciPath = nil

function getMCIPath()
	if(mciPath == nil) then
		mciPath = modPath
		LOG(repr(__active_mods))

		for i, m in __active_mods do
		   	if(m['uid'] == '89BF1572-9EA8-11DC-1313-635F56D89591') then
   				mciPath = m['location'] .. '/'
   			end
		end
	end

	return string.lower(mciPath)
end

function currentTick()
	return current_tick
end

function addListener(callback, wait, option)
	table.insert(listeners, {callback=callback, wait=wait, option=option})
end

function mainThread()

	while(true)  do
		for _, l in listeners do
			local current_second = current_tick * WAIT_SECONDS

			if(math.mod(current_second*10, l['wait']*10) == 0) then
				l['callback']()
			end
		end

		current_tick = current_tick + 1
		WaitSeconds(WAIT_SECONDS)
	end
end

function watchdogThread()
	while(true) do
		if(watch_tick == current_tick) then -- main thread has died
			print "EM: mainThread crashed! Restarting..."

			if(mThread) then 
				KillThread(mThread)
			end

			mThread = ForkThread(mainThread)
		end

		watch_tick = current_tick

		WaitSeconds(1)
	end
end

function setup(isReplay, parent)
	local mods = {'units', 'engineers'}
	
	for _, m in mods do
		import(modPath .. 'modules/' .. m .. '.lua').init(isReplay, parent)
	end
end

function initThreads() 
	ForkThread(mainThread)
	ForkThread(watchdogThread)
end

function init(isReplay, parent)
	setup(isReplay, parent)
	ForkThread(initThreads)
end

