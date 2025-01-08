--!strict
local types = require(script.types)
local util = require(script.util)
local builtin_types = require(script.builtin_types)

local registry: Registry = { commands = {}, types = {} }

type Registry = types.Registry
type Result<T> = types.Result<T>
type ArgumentType = types.ArgumentType
type Argument = types.Argument
type CommandCallback<T...> = types.CommandCallback<T...>
type Command<T...> = types.Command<T...>

local fail, success = util.fail, util.success

local function register_command<T...>(command: Command<T...>): Command<T...>
	registry.commands[command.name] = command
	return command
end

local function register_type(type: ArgumentType): ArgumentType
	registry.types[type.name] = type
	return type
end

local function query(player: Player?, query: string): Result<nil>
	local words = query:gsub("^%s+", ""):split(" ")
	if #words == 0 then
		return success()
	end

	local command = registry.commands[words[1]]
	if not command then
		return fail(`Unknown command "{words[1]}"`)
	end

	if command.checks then
		for _, check in command.checks do
			local result = check(player)
			if not result.success then
				return result
			end
		end
	end

	table.remove(words, 1)

	local command_name = `Command "{command.name}"`

	local arguments = {}
	local expect_optional = true

	for i, arg in command.args do
		local arg_name = `"{arg.name}"` or `"Argument {i}"`
		local full_name = `{command_name} argument "{arg_name}"`

		local expects = 1

		assert(expect_optional, `{full_name} comes after an optional argument`)

		if arg.optional == true then
			expect_optional = false
		end

		if arg.amount then
			if typeof(arg.amount) == "string" then
				assert(i ~= #command.args, `{full_name} can only be variadic if it is the last argument`)
				expects = #words - #arguments
			else
				assert(arg.amount > 0, `{full_name} must have an amount greater than 0`)
				expects = arg.amount
			end
		end

		if expects + #arguments > #words then
			return fail(`{full_name} requires {expects} argument(s)`)
		end

		local deserializer
		if typeof(arg.type) == "string" then
			local type = registry.types[arg.type]
			assert(type, `{full_name} has an unregistered type "{arg.type}"`)

			deserializer = type.deserializer
		else
			deserializer = arg.type.deserializer
		end

		local start_index = #arguments
		for i = 1, expects do
			local word = words[start_index + i]

			if not word then
				return fail(`{command_name} missing argument {arg_name}`)
			end

			local result = deserializer(word)
			if result.success then
				table.insert(arguments, result.value)
			else
				return fail(`{arg_name} failed: {result.reason}`)
			end
		end
	end

	return command.callback(player, table.unpack(arguments))
end

local function register_builtin_types()
	for _, type in builtin_types do
		register_type(type)
	end
end

register_command({
	name = "a",
	args = { { type = "boolean" } },
	callback = function(x, y)
		print(y)
		return success(y)
	end,
})

register_builtin_types()
query(nil, "a true")

return {
	register_command = register_command,
	register_type = register_type,
	query = query,

	success = success,
	fail = fail,

	register_builtin_types = register_builtin_types,
}
