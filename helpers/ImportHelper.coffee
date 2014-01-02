## @module ImportHelper ##

fs = require 'fs'
path = require 'path'

class Import
	@alias:
		pdt: 'pdot'

	@location: {}

	@compiler: {}

	@importLocations: []

	@register: (notation, @rootDir) ->
		global.Import = @importDotNotation.bind this
		global.Importer = this
		@addCompiler 'dot', require('../library/compilers/DotTemplateCompiler'), 'dt'
		@addCompiler 'ini', require '../library/compilers/IniCompiler'
		@addCompiler 'coffee', require('../library/compilers/CoffeeScriptCompiler'), 'cs'
		@addCompiler 'json', require('../library/compilers/CoffeeScriptCompiler'), 'jn'


	@importDotNotation: (toImport) ->
		fileArray = toImport.split /\./g
		[name, extension] = fileArray.pop().split /\$/g
		extension = @extensionAlias extension
		if fileArray.length is 0
			file = @getFile "#{name}.#{extension}"
		else
			fileArray = @locationAlias fileArray
			file = @getFile "#{path.normalize(fileArray.join '/')}/#{name}.#{extension}"
		@compile file.toString(), extension

	@getFile: (file) ->
		for location in @importLocations
			try
				return fs.readFileSync path.normalize "#{location}/#{file}"
			catch e
		fs.readFileSync path.normalize "#{@rootDir}/#{file}"

	@compile: (file, extension) ->
		if @compiler[extension]? then @compiler[extension] file
		else file

	@extensionAlias: (extension) ->
		@alias[extension] || extension

	@locationAlias: (fileArray) ->
		if @location[fileArray[0]] then fileArray[0] = @location[fileArray[0]]
		fileArray

	@addCompiler: (extension, fn, alias = null) ->
		if alias? and typeof alias isnt 'undefined' then @alias[alias] = extension
		@compiler[extension] = fn

	@addLocation: (location) ->
		@importLocations.push location


module.exports = Import