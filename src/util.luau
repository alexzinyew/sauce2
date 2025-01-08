local types = require(script.Parent.types)

local function success<T>(value: T?): types.Result<T>
	return { success = true, value = value }
end

local function fail<T>(reason: string?): types.Result<T>
	return { success = false, reason = reason }
end

return { success = success, fail = fail }
