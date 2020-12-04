mutable struct Node 
	id::Int
	status::Int
	home
	point::Tuple
	seen::Array
	waiting_time::Int
	waited_time::Int
	starting_point::Tuple

	function Node(id::int,status::int,home,point::Tuple,num_cells::Int)
		seen = zeros(Int,num_cells,1)
		new(id,status,home,point,seen,0,0,(0,0))
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
	end
	#TODO: Add wait check
	procede(node,seconds)
	#TODO: Update seen for the cells (Only if arrived at destination? Check paper)
end

#TODO: What the hell means the distance speed descrition?
function procede(node::Node,seconds::Float16)
	# I'm using a fixed value, but it should be constructed
	speed = 1.5
	distance = [ abs(i) for i in (collect(node.home.position) - collect(node.starting_point))]
	
	#TODO: Can i change tuple with vector?
	node.point = node.point + distance * speed * seconds #FIXME: Not working because node.point is a Tuple

	#TODO: If arrived, the node pass to WAITING
end


function choose_destination(node,canvas,alpha,k)
	p = -1;
	current_cell = node.home

	for i in 1:length(canvas.cells)
		for j in 1:length(canvas.cells[i])
			cell = canvas.cells[i][j]
			dist = distance(node,cell,k)
			p_dist = alpha * dist + (1 - alpha) * node.seen[i+j]
			if p < p_dist
				p = p_dist
				current_cell = cell 
			end
		end
	end
	node.home = current_cell
end

function distance(node,cell,k)
	point_distance = round(evaluate(Euclidean(),node.point,cell.position),digits=4)
	return 1 / (((1 + k) * point_distance) ^ 2);
end