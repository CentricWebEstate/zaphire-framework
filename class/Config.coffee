

class Config

	## We keep the below for backwards compatibility
	@config: require('ini').parse (require('fs').readFileSync 'configs/general.ini').toString()
	
	@get: (config) =>
		sp = config.split '.'

		last = @config
		i = 0
		for param in sp
			last = last[param]
			if (i + 2) is sp.length then break
			i++
		env = process.env.LOCATION || 'production'
		return last[env][sp[i+1]]

	## And this will be the new accepted api
	constructor: (config) ->
		@config = Import "#{config}$ini"

	get: (value) ->
		sp = config.split '.'

		last = @config
		i = 0
		for param in sp
			last = last[param]
			if (i + 2) is sp.length then break
			i++
		env = process.env.LOCATION || 'production'
		return last[env][sp[i+1]]


module.exports = Config