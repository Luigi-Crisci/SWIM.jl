
mutable struct Cell
	position::Array{Float64}
	nodes::Set
	l::Int
	x::Int
	y::Int
end

Cell(p,l,x,y) = Cell(p,Set{Node}(),l,x,y)

mutable struct Canvas
	x::Int
	y::Int 
	r::Float16
	cells::Vector{Vector{Cell}}
	num_cells::Int
end

Canvas(x,y,r) = Canvas(x,y,r,[],0)

function initialize(canvas::Canvas)
	l = round(Int,sqrt( (canvas.r^2) / 2))
	
	if canvas.x % l != 0 || canvas.y % l != 0
		return
	end
	
	x = l / 2;
	r = 1
	while x < canvas.x
		c = 1
		y = l / 2
		cells = Vector{Cell}([])
		while  y < canvas.y
			cell = Cell([x,y],l,r,c)
			push!(cells,cell)
			y += l
			c = c + 1
		end
		x += l
		r = r + 1
		push!(canvas.cells,cells)
	end
	canvas.num_cells = canvas.x / l + canvas.y / l
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
	return length(filter(n -> n.position == p, cell.nodes)) != 0
end

function get_cell(canvas::Canvas,p)
	l = round(Int,sqrt( (canvas.r^2) / 2))
	i = ceil(Int,p[1] / l)
	j = ceil(Int,p[2] / l)
	return canvas.cells[i][j]
end

function get_cell_position(canvas::Canvas,p)
	l = round(Int,sqrt( (canvas.r^2) / 2))
	i = ceil(Int,p[1] / l)
	j = ceil(Int,p[2] / l)
	return [i,j]
end

function get_near_cells(canvas::Canvas,p)
	point = get_cell_position(canvas,p)

	max_x = length(canvas.cells)
	max_y =  length(canvas.cells[1])
	if point[1] > max_x || point[2] > max_y
		return
	end
	near_cells = []
	if point[1] > 1
		push!(near_cells,canvas.cells[point[1] - 1][point[2]])
		if point[2] > 1
			push!(near_cells,canvas.cells[point[1] - 1][point[2] - 1])
		end
		if point[2] < max_y
			push!(near_cells,canvas.cells[point[1] - 1][point[2] + 1])
		end
	end
	if point[1] < max_x
		push!(near_cells,canvas.cells[point[1] + 1][point[2]])
		if point[2] < max_y
			push!(near_cells,canvas.cells[point[1] + 1][point[2] + 1])
		end
	end
	if point[2] > 1
		push!(near_cells,canvas.cells[point[1]][point[2] - 1])
		if point[1] < max_x
			push!(near_cells,canvas.cells[point[1] + 1][point[2] - 1])
		end
	end
	if point[2] < max_y
		push!(near_cells,canvas.cells[point[1]][point[2] + 1])
	end

	return near_cells

end
