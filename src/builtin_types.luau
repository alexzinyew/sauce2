local types = require(script.Parent.types)
local util = require(script.Parent.util)

local fail, success = util.fail, util.success

return {
	{
		name = "string",
		deserializer = function(string)
			return success(string)
		end,
	},
	{
		name = "number",
		deserializer = function(string)
			local number = tonumber(string)

			if not number then
				return fail(`Could not convert {string} to number`)
			end

			return success(number)
		end,
	},
	{
		name = "boolean",
		suggestions = { "true", "false" },
		deserializer = function(string)
			return if (string == "true")
				then success(true)
				elseif string == "false" then success(false)
				else fail(`Expected "true" or "false", got {string}`)
		end,
	},
} :: { types.ArgumentType }
