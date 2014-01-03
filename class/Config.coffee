

class Config
	@config: require('ini').parse (require('fs').readFileSync 'configs/general.ini').toString()
	
	@get: (config) =>
		if @overide[config] then return @overide[config]()

		sp = config.split '.'

		last = @config
		for param in sp
			last = last[param]
		return last

	@_port: =>
		if process.env.LOCATION is 'development' then return 8080
		else if process.env.LOCATION is 'staging' then return 80
		else return @config.express.port

	@_host: =>
		if process.env.LOCATION is 'development' then return 'localhost'
		else if process.env.LOCATION is 'staging' then return 'staging.justtender.com'
		else return @config.express.host

	## important to place here otherwise the functions aren't defined ##
	@overide:
		'express.port': @_port
		'express.host': @_host


module.exports = Config