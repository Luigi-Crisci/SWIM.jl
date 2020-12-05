mutable struct Node 
	id::Int
	status::Int
	home
	position::Array
	seen::Array
	waiting_time::Int
	waited_time::Int
	waiting_upper_bound::Int
	starting_position::Array

	function Node(id::int,status::int,home,position::Array,num_cells::Int)
		seen = zeros(Int,num_cells,1)
		new(id,status,home,position,seen,0,0,position)
	end

end

const START = 0
const MOV = 1
const LEAVE = 2
const WAITING = 3

function move(node::Node,canvas::Canvas,time::DateTime,alpha::Float16,k::Float16,seconds::Float16)
	#TODO: Add events here
	if node.status == START 
		choose_destination(node,canvas,alpha,k)
	elseif node.status == WAITING 
		wait_state(node,seconds)
	end

	procede(node,seconds)
	#TODO: Update seen for the cells (Only if arrived at destination? Check paper)
end

#TODO: What the hell means the distance speed descrition?
function procede(node::Node,seconds::Float16)
	# I'm using a fixed value, but it should be constructed
	speed = 1.5
	distance = node.home.position - node.starting_position
	angle = atan(distance[2],distance[1])
	node.position = node.position + [sin(angle),cos(angle)] * speed * seconds # Make the node procede

	if inside_home_cell(node) || have_surpassed_cell(node,angle) #It must be set to the center of the cell
		wait_state(node,seconds)
end

#If the angle between the starting position and the actual position is changed, we have surpassed the home cell
function have_surpassed_cell(node,angle)
	distance = node.home.position - node.position
	return angle != atan(distance[2],distance[1])
end

function choose_destination(node,canvas,alpha,k)
	p = -1;
	current_cell = node.home

	for i in 1:length(canvas.cells)
		for j in 1:length(canvas.cells[i])
			cell = canvas.cells[i][j]
			dist = distance(node,cell,k)
			p_dist = alpha * dist + (1 - alpha) * node.seen[i+j] # Node weight
			if p < p_dist
				p = p_dist
				current_cell = cell 
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

function inside_home_cell(node)
	xl = node.home.position[1] - (node.home.l / 2)
	xr = node.home.position[1] + (node.home.l / 2)
	yt = node.home.position[2] + (node.home.l / 2)
	yb = node.home.position[2] - (node.home.l / 2)
	r = Rect(xl,yb,xr,yt)
	return inside((node.position[1],node.position[2]),r)
end

function wait_state(node,seconds)
	if node.status == WAITING
		node.waited_time += seconds
		if node.waiting_time <= node.waited_time
			node.status = LEAVE
	else
		node.status = WAITING
		node.waiting_time = min(round(rand(Levy(1,2))),node.waiting_upper_bound)
		node.waited_time = 0
	end

end