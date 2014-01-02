class Controller
	_redirecting: false

	constructor: (@request, @response, view, layout) ->
		View = Import 'lib.class.View$cs'
		@view = new View view, @response
		@view.setLayout layout

	beforeLoad: ->

	beforeRender: ->

	redirect: (args...) ->
		if args.length is 2
			@response.redirect args[0], args[1] 
		else
			@response.redirect args[0]
		@_redirecting = true

	render: (viewFile) ->
		viewFile ?= null
		if not @_redirecting then @view.render viewFile

	getQuery: (param, def) ->
		def ?= null
		return @request.query if typeof param is 'undefined' or not param? 
		param = @request.query[param]
		if typeof param is 'undefined' then return def
		param

	getPost: (param, def) ->
		def ?= null
		return @request.body if typeof param is 'undefined' or not param? 
		param = @request.body[param]
		if typeof param is 'undefined' then return def
		param

	getParam: (param, def) ->
		def ?= null
		param = @request.param param
		if typeof param is 'undefined' then return def
		param



module.exports = Controller