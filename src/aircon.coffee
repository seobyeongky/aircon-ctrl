request = require 'request'
builder = require 'xmlbuilder'
xml2json = require 'xml2json'

module.exports = (ip,session) ->
	xml = null
	ops = 
		monitor : ->	
			xml.ele('getMonitoring')
				.ele('all')

		control : (ops) ->
			list = xml.ele('setDeviceControl')
				.ele('controlList')

			addresses = ops.addresses
			delete ops.addresses

			if ops.address?
				addresses = [ops.address]
				delete ops.address

			for k,v of ops		
				control = list.ele('control')
				control.ele('controlValue')
					.ele(k,String(v))
				a = control.ele('addressList')
				addresses.forEach (x) ->
					a.ele('address',x)
	worker = (commands,next) ->	
		xml = builder.create('root')
		xml.ele('header',{sa:'web',da:'dms',messageType:'request'
			,dateTime:(new Date()).toISOString().replace(/[A-Za-z]$/g, '')
			,dvmControlMode:'individual'})		

		for k,v of commands
			if ops[k]?
				ops[k].call null, v

		xml.end(pretty:true)


		j = request.jar()
		j.add request.cookie 'JSESSIONID=' + session
		header = '<uuid>:'
		body = '<?xml version="1.0" encoding="utf-8" standalone="yes"?>' + xml.toString()

		console.log body

		opts = 
			uri:'http://'+ip+'/dms2/dataCommunication'
			body:header + body
			jar:j

		next ?= console.log

		request.post opts, (err,res) ->	
			unless err
				json = xml2json.toJson res.body.substr(header.length)
				next null, JSON.parse(json)
			else
				next err

	ret = {}
	for k,v of ops
		do (k,v) ->
			ret[k] = (conf,next) ->
				if not next? and conf instanceof Function
					next = conf
					conf = null
				o = {}
				o[k] = conf
				worker o, next
	ret

