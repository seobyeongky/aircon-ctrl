{ipaddr,session,airconaddr} = require './conf.json'

async = require 'async'
aircon = (require './src/aircon')(ipaddr, session)


async.series [
	(next) ->
		aircon.control {
			address : airconaddr
			power : "off"
		}, next


	# (next) ->
	# 	aircon.control {
	# 		address : addr
	# 		setTemp : 26
	# 	}, next

], (err) ->
	if err?
		console.log "콘트롤 실패 : ", err
		return





return
aircon.monitor (err,data) ->
	if err?
		console.error "모니터링 에러 : ", err
		return

	console.log data.root.getMonitoring.all


