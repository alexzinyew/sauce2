local typedef = require(script.Parent.typedef)

local function success<T>(value: T?): typedef.Result<T>
	return { success = true, value = value }
end

local function fail<T>(reason: string?): typedef.Result<T>
	return { success = false, reason = reason }
end

local function result<T>(success: boolean, value: string? | T?): typedef.Result<T>
	if success then
		return { success = true, value = value :: T? }
	else
		return { success = false, value = value :: string? }
	end
end

return { success = success, fail = fail, result = result }
