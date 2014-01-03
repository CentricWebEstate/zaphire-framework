module.exports = (express, app, Router, Config, @root) ->
	MongoStore = require('connect-mongo')(express)
	store = new MongoStore
		db: Config.get 'database.name'
		username: Config.get 'database.user'
		password: Config.get 'database.pass'
	=>
		app.use express.compress()
		app.use express.urlencoded()
		app.use express.json()
		app.use express.cookieParser()
		app.use express.session
			secret: Config.get 'express.secret'
			store: @store
			auto_reconnect: true
		app.use express.static "#{@root}/public"
		Router.initRoutes app
		app.use express.directory "#{@root}/public"