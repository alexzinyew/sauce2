# Sauce

Small console command package for Roblox

## Features

* Arguments with custom type deserializers
* Arguments with any amount of words
* Optional arguments
* Commands with "check" functions that run before execution, e.g. permissions

## Installation

### With pesde
There are no releases yet

## Registering

#### Type Registration Example

```luau
sauce.register_type({
	name = "player",
	parameters = 1,
	suggestions = function()
		local names = {}

		for _, player in game:GetService("Players"):GetPlayers() do
			table.insert(names, player.Name)
		end

		return names
	end,

	deserializer = function(name)
		local player = game:GetService("Players"):FindFirstChild(name)

		return sauce.result(player ~= nil, player)
	end,
})
```

### Command Registration Example

```luau
sauce.register_command({
	name = "kill",
	description = "kills provided players from username",

	checks = {
		-- Example check for private server owner
		function(caller: Player?)
			return sauce.result(caller ~= nil and caller.UserId == game.PrivateServerOwnerId)
		end,
	},

	args = {
		{
			name = "names",
			description = "The players to kill",

			type = "player",
			amount = 1, -- Can also be "variadic"

			optional = false,
		},
	},

	callback = function(caller, player: Player)
		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid") :: Humanoid?
			if humanoid then
				humanoid.Health = 0
			end
		end

		return sauce.success()
	end,
})
```

## Builtin Types

`string`, `boolean`, and `number` types are automatically registered when the `register_builtin_types` function is called

## Querying

Queries are run through the `query` function, example:

```luau
sauce.query(localplayer, "add 4 6 9")
```
