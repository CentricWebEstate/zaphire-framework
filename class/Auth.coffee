Logger = Import 'helpers.LoggerHelper$cs'
Mongo = require 'mongojs'

class Auth
	config: Import 'configs.auth$ini'

	constructor: ->
		@db = Mongo.connect @config.database.dsn, @config.database.collections

	tempCreation: (name, email) ->
		update = 
			email: email
		document = 
			email: email
			password: ''
			username: ''
			name: name

		@db.users.update update, document, {upsert:true}, (err, success) ->
			Logger.warn "@Auth: Failed to save user." if err or not success

module.exports = Auth