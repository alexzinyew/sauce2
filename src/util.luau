local typedef = require(script.Parent.typedef)

local function success<T>(value: T?): typedef.Result<T>
	return { success = true, value = value }
end

local function fail<T>(reason: string?): typedef.Result<T>
	return { success = false, reason = reason }
end

return { success = success, fail = fail }
