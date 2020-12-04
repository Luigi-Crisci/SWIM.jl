mutable struct Node 
	id::Int
	status::Int
	home
	point::Tuple
	seen::Array

	function Node(id::int,status::int,home,point::Tuple,num_cells::Int)
		seen = zeros(Int,num_cells,1)
		new(id,status,home,point,seen)
	end

end

const START = 0
const MOV = 1
const LEAVE = 2
const STOP = 3

function move(node::Node,canvas::Canvas,time::DateTime,alpha::Float16,k::Float16)
	if node.status == START || node.status == STOP
		choose_destination(node,canvas,alpha)
		

end


function choose_destination(node,canvas,alpha)
	dest = -1;
	for cell in canvas.cells
		dest = max(dest,distance(node,cell))
	end
	node.home = 
end

function distance(node,cell,k)
	point_distance = round(evaluate(Euclidean(),node.point,cell.position),digits=4)
	return 1 / (((1 + k) * point_distance) ^ 2);
end