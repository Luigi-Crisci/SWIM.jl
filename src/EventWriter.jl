const MM = 2
const LM = 3
const MP = 4
const LP = 5

struct Event
	id_node1::Int
	id_node2::Int
	position_node1::Array
	position_node2::Array
	type::Int
	time::DateTime
end

struct EventWriter
	file
	queue::Queue{Event}

	function EventWriter(filename::String)
		file = open(filename,"w+")
		queue = Queue{Event}()
		new(file,queue)
	end
end


function add_event(event_writer::EventWriter,event::Event)
	enqueue!(event_writer.queue,event)
end

function write_events(event_writer::EventWriter)
	for event in event_writer.queue
		write(event_writer.file,"$(event.time);$(event.id_node1);$(event.id_node2);$(event.type);$(event.position_node1);$(event.position_node2)\n")
		dequeue!(event_writer.queue)
	end
end

function close_writer(event_writer::EventWriter)
	write_events(event_writer)
	close(event_writer.file)
end


function define_event_and_add(event_writer,node,near_node,time)
	if near_node in node.node_seen
		return false
	end
	type = near_node.status + node.status
	add_event(event_writer, Event(node.id,near_node.id,node.position,near_node.position,type,time))
	return true
end