function simulate(canvas::Canvas,nodes,seconds::Int,delta::Float64)
	time = DateTime(0)
	finish_time = time + Dates.Second(seconds)
	event_writer = EventWriter("log.log")
	# Start simulation
	while time < finish_time
		for node in nodes
			update_seen(node,canvas,event_writer,time)
		end
		for node in nodes
			move(node,canvas,0.5,0.5,delta)
		end
		reset_nodes(nodes)
		time += Dates.Second(delta)
	end
	close_writer(event_writer)
end

function reset_nodes(nodes)
	for node in nodes
		node.node_seen = Set()
	end
end