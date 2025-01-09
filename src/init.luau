--!strict
local typedef = require(script.typedef)
local util = require(script.util)
local builtin_types = require(script.builtin_types)

type Registry = typedef.Registry
type Result<T> = typedef.Result<T>
type ArgumentType = typedef.ArgumentType
type Argument = typedef.Argument
type CommandCallback<T...> = typedef.CommandCallback<T...>
type Command<T...> = typedef.Command<T...>

local registry: Registry = { commands = {}, types = {} }

local fail, success, result = util.fail, util.success, util.result

local function register_command<T...>(command: Command<T...>): Command<T...>
	registry.commands[command.name] = command
	return command
end

local function register_type(type: ArgumentType): ArgumentType
	registry.types[type.name] = type
	return type
end

local function query(player: Player?, query: string): Result<nil>
	local parameters = query:gsub("^%s+", ""):split(" ")
	if #parameters == 0 then
		return success()
	end

	local command = registry.commands[parameters[1]]
	if not command then
		return fail(`Unknown command "{parameters[1]}"`)
	end

	if command.checks then
		for _, check in command.checks do
			local result = check(player)
			if not result.success then
				return result
			end
		end
	end

	table.remove(parameters, 1)

	local command_name = `Command "{command.name}"`

	local arguments = {}
	local expect_optional = true

	for i, arg in command.args do
		local arg_name = if arg.name then `"{arg.name}"` else `"Argument {i}"`
		local full_name = `{command_name} argument {arg_name}`

		local arg_amount = 1
		local type_amount = 1

		assert(expect_optional, `{full_name} comes after an optional argument`)

		if arg.optional == true then
			expect_optional = false
		end

		local deserializer
		if typeof(arg.type) == "string" then
			local type = registry.types[arg.type]
			assert(type, `{full_name} has an unregistered type "{arg.type}"`)

			deserializer = type.deserializer
			type_amount = math.abs(type.parameters or 1)
		else
			deserializer = arg.type.deserializer
			type_amount = math.abs(arg.type.parameters or 1)
		end

		if arg.amount then
			if typeof(arg.amount) == "string" then
				assert(i == #command.args, `{full_name} can only be variadic if it is the last argument`)

				if #parameters % type_amount ~= 0 then
					return fail(`{full_name} given wrong amount of parameters`)
				end

				arg_amount = #parameters / type_amount
			else
				assert(arg.amount > 0, `{full_name} must have an amount greater than 0`)
				arg_amount = arg.amount
			end
		end

		local param_amount = arg_amount * type_amount

		if param_amount > #parameters then
			return fail(`{full_name} requires {param_amount} parameters(s)`)
		end

		local type_parameters = {}

		for i = 1, param_amount do
			local param = parameters[1]
			table.remove(parameters, 1)

			table.insert(type_parameters, param)

			if i % type_amount ~= 0 then
				continue
			end

			local result = deserializer(table.unpack(type_parameters))

			if result.success then
				table.insert(arguments, result.value)
			else
				return fail(`{arg_name} failed: {result.reason}`)
			end

			table.clear(type_parameters)
		end
	end

	return command.callback(player, table.unpack(arguments)) or success()
end

local function register_builtin_types()
	for _, type in builtin_types do
		register_type(type)
	end
end

return {
	register_command = register_command,
	register_type = register_type,
	query = query,

	success = success,
	fail = fail,
	result = result,

	register_builtin_types = register_builtin_types,
}
