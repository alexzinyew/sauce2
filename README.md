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

### Argument Types
Types are registered with the `register_type` function

A type contains: <br>
`name: string` The name of the type<br>
`amount: number?` The amount of parameters the deserializer takes in, defaults to 1 <br>
`deserializer: (...string) -> Result` The deserializer that takes in the parameters <br>
`suggestions: ( {string} | () -> {string} )?` An optional array of autocompletions<br>

#### Type Registration Example

```luau
sauce.register_type {
    name = "boolean",
    deserializer = function(text)
        if text == "true" then
            return sauce.success(true)
        elseif text == "false" then
            return sauce.success(false)
        end
        
        return sauce.fail("Expected true or false")
    end,
}
```

### Commands
Commands are registered with the `register_command` function

A command contains: <br>
`name: string` The name of the command <br>
`description: string?` The optional description of the command <br>
`callback: (Player?, ...) -> Result` The function that runs when the command is called <br>
`args: {Argument}` The arguments of the command <br>
`checks: { (Player?) -> Result }?` The checks that must all return successfully before the callback runs

#### Command Registration Example 

```luau
sauce.register_command {
	name = "add",
	args = {
		{
			type = "number",
			amount = "variadic",
		},
	},
	callback = function(player, ...: number)
		local sum = 0

		for _, number in { ... } do
			sum += number
		end

		print(sum)

		return sauce.success()
	end,
}
```

## Arguments

Arguments are not registered, but are instead contained inside a command and use argument types. An example of an argument can be seen in the code sample above

An argument contains: <br>
`name: string?` The name of the argument <br>
`description: string?` The description of the argument <br>
`type: ArgumentType | string` The name of a registered type OR the actual table <br>
`amount: (number | "variadic")?` How many times the parameters will be given to the type's deserializer. (If "variadic", then it can only be used as the last argument) <br>
`optional: boolean?` Whether or not the argument is optional or not (can only be used as the last argument)

## Amounts

Arguments and Argument Types both contain their own `amount` field.

The type's amount field determines how many variables are given to the deserializer, while the argument's amount field determines how many times the type's deserializer will run and be given to the callback.
