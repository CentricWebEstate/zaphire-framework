

class View
	headers:
		'Content-type':'text/html'
	viewVars:
		siteTitle: ''
		headers: ''
	isJson: false
	responseCode: 200

	constructor: (@viewFile, @response) ->

	addHeader: (key, value) ->
		@headers[key] = value

	getHeaders: ->
		@headers

	setJSON: ->
		@headers['Content-type'] = 'application/json'
		@isJson = true

	set: (param, value) ->
		@viewVars[param] = value
		this

	setLayout: (@layout) ->

	setView: (@viewFile) ->

	setHtmlHeaders: (header) ->
		@viewVars.headers = header

	changeResponseCode: (code) ->
		@responseCode = code

	render: (viewFile = null) ->
		return @response.json @responseCode, @viewVars if @isJson

		view = Import viewFile || @viewFile
		if @layout? and typeof @layout isnt 'undefined'
			@viewVars.content = view @viewVars
			layout = Import @layout
			text = layout @viewVars
		else
			text = view @$viewVars
		
		@response.send @responseCode, text

module.exports = View