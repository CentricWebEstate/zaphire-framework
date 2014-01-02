## @module DotTemplateHelper ##

_ = require 'underscore'
Config = require '../class/Config'

class DotTemplate
	@dot: require 'dot'
	@options:
		varname: '$this'
		strip: false

	@compile: (template) =>
		defs = 
			partial: (args...) =>
				Import.apply this, args

			baseUrl: (string) =>
				port = Config.get 'express.port'
				host = Config.get 'express.host'
				baseUrl = Config.get 'view.baseURL'
				if port isnt 80 then host = "#{host}:#{port}"
				else host = "#{host}"
				"//#{host}#{baseUrl}#{string}"
		@dot.template template, (_.extend @dot.templateSettings, @options), defs
			

module.exports = (template) ->
	DotTemplate.compile template