{ipaddr,session,airconaddr} = require './conf.json'

async = require 'async'
aircon = (require './src/aircon')(ipaddr, session)


async.series [
	(next) ->
		aircon.control {
			address : airconaddr
			power : "on"
		}, next


	(next) ->
		aircon.control {
			address : airconaddr
			setTemp : 26
		}, next

], (err) ->
	if err?
		console.log "콘트롤 실패 : ", err
		return
