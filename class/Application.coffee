## @module app ##
Config = Import 'class.Config$cs'

class App
	@express: require 'express.io'
	@server: null

	@start: ->
		if @server then return
		Router = Import 'class.Router$cs'
		@Router = new Router()
		@createServer()  ## Create and configure server
		@startSocket()	## Init the socket.io
		@server.listen Config.get 'express.port'  ## Begin listening
		

	@createServer: ->
		http = require 'http'
		@app = @express()
		path = require 'path'
		Bootstrap = Import 'bootstrap$cs'
		configure = new Bootstrap @express, @app, @Router, Config, @root
		@app.configure configure
		@server = http.createServer @app

	@startSocket: ->
		@app.http().io()

if not module? then App.start()
else module.exports = App