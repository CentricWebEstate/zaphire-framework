## @module mail ##

nodemailer = require 'nodemailer'
Logger = Import 'helpers.LoggerHelper$cs'

class Mail
	config: Import 'configs.mail$ini'
	mailOptions: {}
	
	constructor: ->
		@transport = nodemailer.createTransport @config.transport, @config.settings
		@mailOptions.from = 'justTender No-Reply <no-reply@justTender.com>'

	setRecipient: (email) ->
		@mailOptions.to = "<#{email}>"
		this

	setBody: (body, type) ->
		type ?= 'html'

		switch type
			when 'html' then @mailOptions.html = body
			when 'text' then @mailOptions.text = body
		this

	setBodyFromTemplate: (template, vars, type) ->
		type ?= 'html'
		body = Import template


		switch type
			when 'html' then @mailOptions.html = body vars
			when 'text' then @mailOptions.text = body vars
		this

	setSubject: (subject) ->
		@mailOptions.subject = subject
		this

	mail: ->
		@transport.sendMail @mailOptions, (err, res) ->
			if res?.failedRecipients?.length is 0
				Logger.log '@Mailer: Successfully sent message'



module.exports = Mail