## @module Logger ##

class Logger
	# Bitwise Log Levels
	@E_LOG: 1
	@E_NOTICE: 2
	@E_WARN: 4
	@E_ERROR: 8
	@E_ALL: 15

	@log: (args...) ->
		if @canOutput @E_LOG then process.stdout.write "#{@outputWorker()}#{argument.toString()}\n" for argument in args

	@notice: (args...) ->
		if @canOutput @E_NOTICE then process.stdout.write "#{@outputWorker()}[NOTICE] #{argument.toString()}\n" for argument in args

	@warn: (args...) ->
		if @canOutput @E_WARN then process.stdout.write "#{@outputWorker()}[WARN] #{argument.toString()}\n" for argument in args

	@error: (args...) ->
		if @canOutput @E_ERROR then process.stderr.write "#{@outputWorker()}[ERROR] #{argument.toString()}\n" for argument in args

	@canOutput: (level) -> 
		defaultLevel = 12
		if process.env.LOG_LEVEL? and typeof process.env.LOG_LEVEL isnt 'undefined'
			process.env.LOG_LEVEL & level
		else
			defaultLevel & level

	@outputWorker: ->
		cluster = require 'cluster'
		if cluster.isWorker then "worker##{cluster.worker.id} "
		else 'master#0 '

module.exports = Logger