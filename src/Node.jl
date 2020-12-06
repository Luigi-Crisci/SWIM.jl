const START = 0
const MOV = 1
const LEAVE = 2
const WAITING = 3

mutable struct Node 
	id::Int
	status::Int
	home::Array
	position::Array
	current_cell::Array
	seen::Array
	waiting_time::Int
	waited_time::Int
	starting_position::Array
	waiting_upper_bound::Int
	node_seen::Set

	function Node(id::Int,status::Int,home,position::Array,cells_num::Array,upper_bound::Int)
		seen = zeros(Int,cells_num[1],cells_num[2])
		new(id,status,home,position,home,seen,0,0,position,upper_bound,Set())
	end

end

function move(node::Node,canvas::Canvas,alpha::Float64,k::Float64,seconds::Float64)
	if node.status == START  || node.status == LEAVE
		choose_destination(node,canvas,alpha,k)
		procede(node,canvas,seconds)
		return
	elseif node.status == WAITING 
		wait_state(node,seconds)
		return
	end
	#Moving state
	procede(node,canvas,seconds)
end

#TODO: What the hell means the distance speed descrition?
function procede(node::Node,canvas::Canvas,seconds::Float64)
	node.status = MOV
	# I'm using a fixed value, but it should be constructed
	speed = 1.5
	distance = get_home_cell(node,canvas).position - node.starting_position
	angle = atan(distance[2],distance[1])
	node.position = node.position + [cos(angle),sin(angle)] * speed * seconds # Make the node procede

	if is_inside_home_cell(node,canvas) || has_surpassed_cell(node,angle,canvas)
		fix_surpassed_cell(node,angle,canvas)
		wait_state(node,seconds)
	end

	if get_cell_position(canvas,node.position) != node.current_cell
		delete_node_from_cell(node,canvas,node.current_cell)
		node.current_cell = get_cell_position(canvas,node.position)
		add_node_to_cell(node,canvas,node.current_cell)
	end
end

#If the angle between the starting position and the actual position is changed, we have surpassed the home cell
function has_surpassed_cell(node,angle,canvas)
	distance = get_home_cell(node,canvas).position - node.position
	return angle != atan(distance[2],distance[1])
end

function fix_surpassed_cell(node,angle,canvas)
	if has_surpassed_cell(node,angle,canvas)
		node.position = get_home_cell(node,canvas).position
	end
end

function choose_destination(node,canvas,alpha,k)
	p = -1;
	current_cell = node.home

	for i in 1:length(canvas.cells)
		for j in 1:length(canvas.cells[i])
			cell = canvas.cells[i][j]
			dist = distance(node,cell,k)
			p_dist = alpha * dist + (1 - alpha) * node.seen[i,j] # Node weight
			if p < p_dist
				p = p_dist
				current_cell = [i,j]
			end
		end
	end
	node.home = current_cell
	node.starting_position = node.position
end

#Distance formula from the paper
function distance(node,cell,k)
	position_distance = round(evaluate(Euclidean(),node.position,cell.position),digits=4)
	return 1 / (((1 + k) * position_distance) ^ 2);
end

function is_inside_home_cell(node,canvas::Canvas)
	home = get_home_cell(node,canvas)
	xl = home.position[1] - (home.l / 2)
	xr = home.position[1] + (home.l / 2)
	yt = home.position[2] + (home.l / 2)
	yb = home.position[2] - (home.l / 2)
	r = Rect(xl,yb,xr,yt)
	return inside((node.position[1],node.position[2]),r)
end

function wait_state(node,seconds)
	if node.status == WAITING
		node.waited_time += seconds
		if node.waiting_time <= node.waited_time
			node.status = LEAVE
		end
	else
		node.status = WAITING
		node.waiting_time = min(round(rand(Levy(1,2))),node.waiting_upper_bound)
		node.waited_time = 0
	end
end


#TODO: This should generate float points
function generate_nodes(canvas::Canvas,n::Int,waiting_upper_bound::Int)
	nodes = []
	cells_num = [ length(canvas.cells),length(canvas.cells[1]) ]
	for i in 1:n
		p = generate_point(canvas)
		node = Node(i,0,get_cell_position(canvas,p),p,cells_num,waiting_upper_bound)
		add_node_to_home_cell(node,canvas)
		push!(nodes,node)
	end
	return nodes
end

function get_home_cell(node::Node,canvas::Canvas)
	return canvas.cells[node.home[1]][node.home[2]]
end

function add_node_to_home_cell(node,canvas)
	push!(get_home_cell(node,canvas).nodes,node)
end

function add_node_to_cell(node,canvas,cell)
	push!(canvas.cells[cell[1]][cell[2]].nodes,node)
end

function delete_node_from_cell(node,canvas,cell)
	delete!(canvas.cells[cell[1]][cell[2]].nodes,node)
end

function update_seen(node::Node,canvas::Canvas,event_writer::EventWriter,time::DateTime)
	node.seen[node.home[1],node.home[2]] = length(get_home_cell(node,canvas).nodes) - 1

	for near_node in get_home_cell(node,canvas).nodes
		if near_node.id == node.id
			continue
		end
		if define_event_and_add(event_writer,node,near_node,time)
			push!(near_node.node_seen,node)
		end
	end

	near_cells = get_near_cells(canvas,node.position)
	for cell in near_cells
		node.seen[cell.x,cell.y] = 0

		for near_node in cell.nodes
			dist = evaluate(Euclidean(),node.position,near_node.position)
			if dist <= canvas.r
				if define_event_and_add(event_writer,node,near_node,time)
					push!(near_node.node_seen,node)
				end
				node.seen[cell.x,cell.y] += 1
			end
		end
	end
end

