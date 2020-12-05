
mutable struct Cell
	position::Array{Float64}
	nodes::Set{Node}
	l::Int
end

Cell(p,l) = Cell(p,Set{Node}(),l)

mutable struct Canvas
	x::Int
	y::Int 
	r::Int
	cells::Vector{Vector{Cell}}
	num_cells::Int
end

Canvas(x,y,r) = Canvas(x,y,r,[],0)

function initialize(canvas::Canvas)
	l = round(Int,sqrt( (canvas.r^2) / 2)) #FIXME:
	
	if canvas.x % l != 0 || canvas.y % l != 0
		return
	end
	
	x = l / 2;
	while x < canvas.x
		y = l / 2
		cells = Vector{Cell}([])
		while  y < canvas.y
			cell = Cell([x,y],l)
			push!(cells,cell)
			y += l
		end
		x += l
		push!(canvas.cells,cells)
	end
	canvas.num_cells = canvas.x / l + canvas.y / l
end

function generate_nodes(canvas::Canvas,n::Int)
	#TODO: Add custom distribution
	nodes = []
	for i in 1:n
		p = generate_point(canvas)
		node = Node(i,0,get_cell(canvas,p),p,canvas.num_cells)
		push!(nodes,node)
	end
	return nodes
end

function generate_point(canvas::Canvas)
	while true
		p = [rand(1:canvas.x),rand(1:canvas.y)]
		if !is_occupied(canvas,p)
			return p
		end
	end
end

function is_occupied(canvas::Canvas,p)
	cell = get_cell(canvas,p)
	return lenght(filter(n -> n.point == p, cell.nodes) != 0)
	
end

function get_cell(canvas::Canvas,p)
	l = canvas.r ^ 2
	i = ceil(Int,p[1] / l)
	j = ceil(Int,p[2] / l)
	return canvas.cells[i][j]
end

