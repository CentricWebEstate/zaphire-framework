## modules RouterClass ##

Logger = Import 'helpers.LoggerHelper$cs'

class Router

	initRoutes: (app) ->
		@config = Import 'configs.routes$ini'

		Logger.log '@Router: Initialised Default Route'

		for key, route of @config.routes
			Logger.log "@Router: Initialising route #{key}"
			switch route.method
				when 'standard'
					app.get route.path, @routeHelper(route)
					app.post route.path, @routeHelper(route)

				when 'all'
					app.all route.path, @routeHelper(route)
				else
					app[route.method] route.path, @routeHelper.bind this

		app.all '/:controller/:action?/:view?', @default

		fs = require 'fs'
		path = require 'path'

		###
		## Commented out because of lacking support MacOSX
		fs.watch path.normalize('../../config/routes.ini'), { persistent: false, }, (event, filename) =>
			@config = Import 'config.routes$ini'
			Logger.log '@Router: routes.ini changed. Reloading routes.'
			app.routes = {}
			for key, route of @config.routes
				Logger.log "@Router: Initialising route #{key}"
				switch route.method
					when 'standard'
						app.get route.path, @routeHelper(route)
						app.post route.path, @routeHelper(route)

					when 'all'
						app.get route.path, @routeHelper(route)
						app.post route.path, @routeHelper(route)
						app.put route.path, @routeHelper(route)
						app.delete route.path, @routeHelper(route)
					else
						app[route.method] route.path, @routeHelper.bind this

			###


	loadController: (controller) ->
		try
			Import "#{@config.defaults.location.controllers}.#{controller}$#{@config.defaults.extension}"
		catch error
			false


	runRoute: (routeObj, serverObj) ->
		Controller = @loadController routeObj.controller
		View = "#{@config.defaults.location.views}.#{routeObj.view}$#{@config.defaults.viewextension}"
		Layout = "#{@config.defaults.location.layouts}.#{routeObj.layout}$#{@config.defaults.viewextension}"

		if Controller is false then return @errorHandler 404, routeObj, serverObj

		try
			controller = new Controller serverObj.req, serverObj.res, View, Layout
			if controller?[routeObj.action]
				controller.error = routeObj.error if typeof routeObj.error isnt 'undefined'
				controller.beforeLoad?()
				controller[routeObj.action]()
				controller.beforeRender?()
				controller.render()
			else
				@errorHandler 404, routeObj, serverObj
		catch error
			routeObj.error = error
			return @errorHandler 501, routeObj, serverObj


	default: (req, res, next) =>
		controller = req.params.controller
		if typeof controller is 'undefined' then return @errorHandler 404, {}, 
			res: res
			req: req
			next: next
		action = req.params.action || 'main'
		view = req.params.view || controller.toLowerCase()
		controller = controller.charAt(0).toUpperCase() + controller[1...controller.length] + 'Controller'

		routeObj = 
			controller: controller
			action: action
			view: view
			layout: 'main'

		serverObj =
			res: res
			req: req

		@runRoute routeObj, serverObj

	routeHelper: (route) ->

		(req, res, next) =>
			controller = req.params.controller || route.controller
			action = req.params.action || route.action
			view = req.params.view || route.view
			if not route.layout? then route.layout = 'main'

			routeObj =
				controller: controller
				action: action
				view: view
				layout: req.params.layout || route.layout

			serverObj =
				res: res
				req: req

			@runRoute routeObj, serverObj

	errorHandler: (type, routeObj, serverObj) ->
		serverObj.req.oldReq = routeObj
		newRouteObj = 
			controller: @config.errors[type].controller
			action: @config.errors[type].action
			view: @config.errors[type].view
			layout: @config.errors[type].layout
			error: routeObj.error

		@runRoute newRouteObj, serverObj



module.exports = Router