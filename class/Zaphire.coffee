

class Zaphire
	constructor: ->
		path = require 'path'
		ImportHelper = require '../helpers/ImportHelper'
		ImportHelper.register '.', path.resolve __dirname, '../'

	start: ->
		Importer.addLocation @root
		config = Import @config
		LoadBalancer = Import 'class.LoadBalancer$cs'
		LoadBalancer = new LoadBalancer config, [@root]
		Logger = Import 'helpers.LoggerHelper$cs'
		fs = require 'fs'

		fs.writeFileSync(config.pidfile, process.pid) if process.env.LOCATION isnt 'development'

		Logger.notice "##{process.pid} Application is starting."
		LoadBalancer.startBalancer()

		LoadBalancer.cluster.on '@lb:started', ->
			Logger.notice "##{process.pid} Application is ready."


		process.on 'SIGINT', ->
			Logger.notice "##{process.pid} Application is terminating forcefully."
			fs.unlinkSync(config.pidfile) if process.env.LOCATION isnt 'development'
			process.exit 0

		process.on 'SIGTERM', ->
			Logger.notice "##{process.pid} Application is terminating forcefully."
			fs.unlinkSync(config.pidfile) if process.env.LOCATION isnt 'development'
			process.exit 0

	getApp: ->
		Importer.addLocation @root
		App = Import 'class.Application$cs'
		App.root = @root
		App

module.exports = new Zaphire()