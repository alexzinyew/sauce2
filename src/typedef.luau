export type Registry = { types: { [string]: ArgumentType }, commands: { [string]: Command<...any> } }

export type Result<T = nil> = { success: true, value: T? } | { success: false, reason: string? }

export type ArgumentType = {
	name: string,
	parameters: number?,
	suggestions: ((() -> { string }) | { string })?,
	deserializer: (...string) -> Result<any>,
}

export type Argument = {
	name: string?,
	description: string?,
	type: ArgumentType | string,
	amount: (number | "variadic")?,
	optional: boolean?,
}

export type CommandCallback<T...> = (player: Player?, T...) -> Result

export type Command<T...> = {
	name: string,
	description: string?,
	callback: CommandCallback<T...>,
	args: { Argument },
	checks: { (player: Player?) -> Result }?,
}

return {}
