local version = { major = 0, minor = 3, patch = 1 }

local apply = require("./apply")
local batch = require("./batch")
local cleanup = require("./cleanup")
local context = require("./context")
local create = require("./create")
local derive = require("./derive")
local effect = require("./effect")
local mount = require("./mount")
local read = require("./read")
local root = require("./root")
local show = require("./show")
local source = require("./source")
local switch = require("./switch")
local untrack = require("./untrack")
local indexes, values = require("./maps")()
local spring, update_springs = require("./spring")()
local action = require("./action")()
local changed = require("./changed")
local flags = require("./flags")

export type Source<T> = source.Source<T>
export type source<T> = Source<T>
export type Context<T> = context.Context<T>
export type context<T> = Context<T>

local function step(dt: number)
	if game then
		debug.profilebegin("VIDE STEP")
		debug.profilebegin("VIDE SPRING")
	end

	update_springs(dt)

	if game then
		debug.profileend()
		debug.profileend()
	end
end

local stepped = game and game:GetService("RunService").Heartbeat:Connect(function(dt: number)
	task.defer(step, dt)
end)

local vide = {
	version = version,

	-- core
	root = root,
	mount = mount,
	create = create,
	source = source,
	effect = effect,
	derive = derive,
	switch = switch,
	show = show,
	indexes = indexes,
	values = values,

	-- util
	cleanup = cleanup,
	untrack = untrack,
	read = read,
	batch = batch,
	context = context,

	-- animations
	spring = spring,

	-- actions
	action = action,
	changed = changed,

	-- flags
	strict = (nil :: any) :: boolean,
	defer_nested_properties = (nil :: any) :: boolean,

	-- temporary
	apply = function(instance: Instance)
		return function(props: { [any]: any })
			apply(instance, props)
			return instance
		end
	end,

	-- runtime
	step = function(dt: number)
		if stepped then
			stepped:Disconnect()
			stepped = nil
		end
		step(dt)
	end,
}

setmetatable(vide :: any, {
	__index = function(_, index: unknown): ()
		if flags[index] == nil then
			error(`{tostring(index)} is not a valid member of vide`, 0)
		else
			return flags[index]
		end
	end,

	__newindex = function(_, index: unknown, value: unknown)
		if flags[index] == nil then
			error(`{tostring(index)} is not a valid member of vide, 0`)
		else
			flags[index] = value
		end
	end,
})

return vide
