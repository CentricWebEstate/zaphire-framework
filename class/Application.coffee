## @module app ##
Config = Import 'library.class.Config$cs'

class App
	@express: require 'express.io'
	@server: null
	@MongoStore: require('connect-mongo')(@express)

	@start: ->
		if @server then return

		Router = Import 'library.class.RouterClass$cs'
		@Router = new Router()
		@createServer()  ## Create and configure server
		@startSocket()	## Init the socket.io
		@runPreStart()
		@server.listen Config.get 'express.port'  ## Begin listening
		

	@createServer: ->
		http = require 'http'
		@store = new @MongoStore
			db: Config.get 'database.name'
			username: Config.get 'database.user'
			password: Config.get 'database.pass'
		@app = @express()
		path = require 'path'
		configure =  =>
			@app.use (req, res, next) =>
				if req.host isnt Config.get 'express.host'
					return res.redirect 301, "http://#{Config.get 'express.host'}" if (Config.get 'express.port') is 80
					return res.redirect 301, "http://#{Config.get 'express.host'}:#{Config.get 'express.port'}"
				next()
			@app.use @express.compress()
			@app.use @express.urlencoded()
			@app.use @express.json()
			@app.use @express.cookieParser()
			@app.use @express.session
				secret: Config.get 'express.secret'
				store: @store
				auto_reconnect: true
			@app.use @express.static "#{__dirname}/../public"
			@Router.initRoutes @app
			@app.use @express.directory "#{__dirname}/../public"
		@app.configure configure

		@server = http.createServer @app

	@startSocket: ->
		@app.http().io()

	@runPreStart: ->
		PreLaunch = Config.get 'PreLaunch'
		if PreLaunch?.file?.length isnt 0
			for file in PreLaunch.file
				Import "prelaunch.#{file}"

if not module.exports? then App.start()
else App.start()