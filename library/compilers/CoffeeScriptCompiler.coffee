CoffeeScript = require 'coffee-script-redux'
module.exports = (input) ->
	csAst = CoffeeScript.parse input, raw: true
	jsAst = CoffeeScript.compile csAst
	js = CoffeeScript.js jsAst
	module = {}
	eval js
	module.exports