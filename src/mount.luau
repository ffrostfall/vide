local apply = require("./apply")
local root = require("./root")

local function mount<T>(component: () -> T, target: Instance?): () -> ()
	return root(function()
		local result = component()
		if target then
			apply(target, { result })
		end
	end)
end

return mount :: (<T>(component: () -> T, target: Instance) -> () -> ()) & ((component: () -> ()) -> () -> ())
