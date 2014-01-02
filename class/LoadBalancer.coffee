## @module LoadBalancer ##

Logger = Import 'helpers.LoggerHelper$cs'
_ = require 'underscore'

class LoadBalancer
	cluster: require 'cluster'
	cpus: require('os').cpus().length
	numWorkers: 0
	firstRun: 1
	errorBalance: 4
	errorTimeout: 4
	errorCount: 0
	waitTime: 10
	restarts: 0
	register: {}

	constructor: (@config) ->

	startBalancer: ->
		Logger.log "@LoadBalancer: Starting Balancer"
		@setupCluster()
		@cluster.on 'online', (worker) =>
			Logger.log "@LoadBalancer: Worker id##{worker.id} came online. Checking for other processes to fork."
			# worker.process.stderr.pipe()
			@forkProcess()

		@cluster.on 'exit', (worker, code, signal) =>
			if signal? then Logger.log "@LoadBalancer: Worker id##{worker.id} died on signal #{signal}" 
			else Logger.log "@LoadBalancer: Worker id##{worker.id} died and returned code #{code}"
			@numWorkers--
			if code isnt 8 then @forkProcess()
			else @registerError worker

		process.on 'SIGUSR2', =>
			Logger.notice '@LoadBalancer: Recieved SIGUSR2 - Gracefully restarting processes.'
			@gracefulRestart()

		@forkProcess()

	setupCluster: ->
		@cluster.setupMaster
			exec: 'src/system.js'
			silent: false

	forkProcess: ->
		processes = @config.workers_per_core * @cpus
		processes = @config.minimum_workers if processes < @config.minimum_workers
		if processes > @numWorkers
			Logger.log '@LoadBalancer: Process can be forked. Forking...'
			@startProcess = setTimeout (=> 
				@numWorkers++
				@cluster.fork().on 'listening', =>
					@cluster.emit '@wk:loaded'
			), 1000
		else
			Logger.log '@LoadBalancer: No more processes to fork'
			if @firstRun is 1
				@firstRun = 0
				@cluster.emit '@lb:started'

	gracefulRestart: () ->
		workers = _.values @cluster.workers
		Logger.log "@LoadBalancer: Killing #{workers.length} workers."
		doKill = (i, workers) =>
			if not workers[i]? and typeof workers[i] is 'undefined' then return
			Logger.notice "@LoadBalancer: Worker id##{workers[i].id} is getting killed."
			workers[i].kill()
			@cluster.once '@wk:loaded', (worker) =>
				doKill ++i, workers
		doKill 0, workers

	registerError: (worker) ->
		if (@errorCount) < @errorBalance
			Logger.warn "@LoadBalancer: Worker##{worker.id} had an uncaught exception and has caused the stack to be restarted"
			@gracefulRestart()
			@errorCount++
		else
			@errorCount = 0
			if @restarts > 2
				waitTime = @waitTime + (@restarts/2 * 5)
			else waitTime = @waitTime
			Logger.warn "@LoadBalancer: Worker##{worker.id} had an uncaught exception."
			Logger.error "@LoadBalancer: Too many errors within #{@errorBalance} seconds. Trying again in #{waitTime} seconds (#{@restarts} restart[s])."
			++@restarts
			clearTimeout @startProcess
			clearTimeout @restartTimer
			setTimeout (=>
				@forkProcess()
				@restartTimer = setTimeout (=>
					@restarts = 0
				), waitTime * 2000
			), waitTime * 1000

module.exports = LoadBalancer