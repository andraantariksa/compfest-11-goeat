require_relative "disjoinset"
require_relative "driver"
require_relative "restaurant"
require "set"

# Cellular Automata Map Generation
#
# - Create a map (or a rectangle or a 2 dimentional array) with a certain size (`width` x `height`) consist of "wall" as it's elements
# - Set up the border, so the border wouldn't be used
# - Pick a random `(width * height) * walls_percentage` map element and change them into a "floor"

class Map
    attr_reader :drivers, :restaurants, :map

    def initialize(width, height, walls_percentage)
        @width = width
        @height = height
        @area = width * height
        @walls_percentage = walls_percentage
        @map = []
        @center_point = [width / 2, height / 2]
        @disjoinset = DisjointSet.new

        # Constant value for objects on the map
        @PERMANENT_WALL = 0
        @WALL = 1
        @FLOOR = 2
        @PATH = 3
        @DRIVER = 4
        @RESTAURANT = 5
        @USER = 7

        @drivers = []
        @restaurants = []

        generate_initial_map()
        set_border()
    end

=begin
    def map_toml
        map_data = {}

        map_temp = @map
        for y in 0...map_temp.length
            for x in 0...map_temp[y].length
                if map_temp[y][x].instance_of?(Driver)
                    map_temp[y][x] = @DRIVER
                elsif map_temp[y][x].instance_of?(Restaurant)
                    map_temp[y][x] = @RESTAURANT
                end
            end
        end

        map_data["map"] = map_temp

        map_data["drivers"] = @drivers.map do |element|
            driver_obj = element["object"]
            {
                "coord" => element["coord"],
                "object" => {
                    "name" => driver_obj.name,
                    "rating" => driver_obj.rating,
                    "plate" => driver_obj.plate,
                    "first_time" => driver_obj.first_time,
                }
            }
        end

        map_data["restaurants"] = @restaurants.map do |element|
            restaurant_obj = element["object"]
            {
                "coord" => element["coord"],
                "object" => {
                    "name" => restaurant_obj.name,
                    "menu" => restaurant_obj.menu,
                },
            }
        end

        map_data
    end
=end

    def from_data(data)
        @map = data["map"]
        for driver in data["drivers"]
            driver_obj_rep = driver["object"]
            driver_obj_real = Driver.new
            driver_obj_real.name = driver_obj_rep["name"]
            driver_obj_real.plate = driver_obj_rep["plate"]
            driver_obj_real.rating = driver_obj_rep["rating"]
            driver_obj_real.first_time = driver_obj_rep["first_time"]
            x, y = driver["coord"]
            @map[y][x] = driver_obj_real
            @drivers.push({
                            "coord" => driver["coord"],
                            "object" => driver_obj_real
            })
        end

        for restaurant in data["restaurants"]
            restaurant_obj_rep = restaurant["object"]
            restaurant_obj_real = Restaurant.new
            restaurant_obj_real.name = restaurant_obj_rep["name"]
            restaurant_obj_real.menu = restaurant_obj_rep["menu"]
            x, y = restaurant["coord"]
            @map[y][x] = restaurant_obj_real
            @restaurants.push({
                                "coord" => restaurant["coord"],
                                "object" => restaurant_obj_real
            })
        end
    end

    def generate
        random_open_space
        clear_random_open_space
        join_rooms
        clear_small_wall
        @map
    end

    def show_map
        for row in @map
            row_to_print = []
            for item in row
                if item == @FLOOR
                    row_to_print.push(" ")
                elsif item == @USER
                    row_to_print.push("\e[32m@\e[0m") # @ with green color
                elsif item.instance_of?(Driver)
                    row_to_print.push("D")
                elsif item.instance_of?(Restaurant)
                    row_to_print.push("R")
                else
                    row_to_print.push("#")
                end
            end
            puts row_to_print.join(" ")
        end
    end

    def generate_initial_map
        for _ in 0...@height
            temp = []
            for _ in 0...@width
                temp.push(@WALL)
            end
            @map.push(temp)
        end
    end

    # Set up the border to be "unbreakable"
    def set_border()
        for row_i in 0...@height
            @map[row_i][0] = @PERMANENT_WALL
            @map[row_i][@width - 1] = @PERMANENT_WALL
        end

        for column_i in 0...@width
            @map[0][column_i] = @PERMANENT_WALL
            @map[@height - 1][column_i] = @PERMANENT_WALL
        end
    end

    def random_open_space
        total_open_space = (@area * @walls_percentage).to_i

        while total_open_space > 0
            random_row = rand(1...@height - 1)
            random_column = rand(1...@width - 1)

            if @map[random_row][random_column] == @WALL
                @map[random_row][random_column] = @FLOOR
                total_open_space -= 1
            end
        end
    end

    def clear_random_open_space
        for row_i in 1...@height - 1
            for column_i in 1...@width - 1
                total_wall = count_adjacent_wall(row_i, column_i)

                if @map[row_i][column_i] == @FLOOR
                    if total_wall > 5
                        @map[row_i][column_i] = @WALL
                    end
                elsif total_wall < 4
                    @map[row_i][column_i] = @FLOOR
                end
            end
        end
    end

    def clear_small_wall
        for row_i in 1...@height - 1
            for column_i in 1...@width - 1
                total_wall = count_adjacent_wall(row_i, column_i)

                if @map[row_i][column_i] == @WALL
                    if total_wall < 2
                        @map[row_i][column_i] = @FLOOR
                        next
                    end
                end
            end
        end
    end

    def put_driver_random(total_driver)
        while total_driver > 0
            random_row = rand(1...@height - 1)
            random_column = rand(1...@width - 1)

            if @map[random_row][random_column] == @FLOOR
                driver = Driver.new
                @map[random_row][random_column] = driver
                @drivers.push({
                                "object" => driver,
                                "coord" => [random_column, random_row]
                })
                total_driver -= 1
            end
        end
    end

    def put_restaurant_random(total_restaurant)
        while total_restaurant > 0
            random_row = rand(1...@height - 1)
            random_column = rand(1...@width - 1)

            if @map[random_row][random_column] == @FLOOR
                restaurant = Restaurant.new
                @map[random_row][random_column] = restaurant
                @restaurants.push({
                                    "object" => restaurant,
                                    "coord" => [random_column, random_row]
                })
                total_restaurant -= 1
            end
        end
    end

    # Put user on given coordinate
    def put_user(coord)
        x_position = coord[0]
        y_position = coord[1]
        if !((0 < x_position && x_position < @width - 1) && (0 < y_position && y_position < @height - 1))
            raise RangeError.new("User coordinate out of map size bound")
        end
        for row in [-1, 0, 1]
            for column in [-1, 0, 1]
                if !(row == 0 && column == 0) && @map[y_position + row][x_position + column] == @WALL
                    @map[y_position + row][x_position + column] = @FLOOR
                end
            end
        end
        @map[y_position][x_position] = @USER
        join_rooms
        clear_small_wall
    end

    # Check surrounding wall
    def count_adjacent_wall(row_i, col_i)
        total = 0

        for another_row in [-1, 0, 1]
            for another_column in [-1, 0, 1]
                if @map[(row_i + another_row)][col_i + another_column] != @FLOOR && !(another_row == 0 && another_column == 0)
                    total += 1
                end
            end
        end
        total
    end

    def union_adjacent_square(row_i, column_i)
        location = [row_i, column_i]

        for another_row in [-1, 0]
            for another_column in [-1, 0]
                # No diagonal -1,-1   -1,1   1,-1   1,1
                if another_row.abs + another_column.abs == 2
                    next
                end
                n_location = [row_i + another_row, column_i + another_column]

                if @map[n_location[0]][n_location[1]] == @FLOOR
                    root1 = @disjoinset.find(location)
                    root2 = @disjoinset.find(n_location)

                    if root1 != root2
                        @disjoinset.union(root1, root2)
                    end
                end
            end
        end
    end

    def join_rooms
        for row_i in 1...@height - 1
            for column_i in 1...@width - 1
                if @map[row_i][column_i] == @FLOOR
                    union_adjacent_square(row_i, column_i)
                end
            end
        end

        all_caves = @disjoinset.split_sets()

        for cave in all_caves.keys()
            join_points(all_caves[cave][0])
        end
    end

    def join_points(current_point)
        next_point = current_point

        while true
            direction = get_tunnel_direction(current_point, @center_point)
            move = rand(0...3)

            if move == 0
                next_point = [current_point[0] + direction[0], current_point[1]]
            elsif move == 1
                next_point = [current_point[0], current_point[1] + direction[1]]
            else
                next_point = [current_point[0] + direction[0], current_point[1] + direction[1]]
            end

            if stop_drawing(current_point, next_point, @center_point, direction)
                return
            end

            root1 = @disjoinset.find(next_point)
            root2 = @disjoinset.find(current_point)

            if root1 != root2
                @disjoinset.union(root1, root2)
            end

            if @map[next_point[0]][next_point[1] - direction[1]] == @WALL
                @map[next_point[0]][next_point[1] - direction[1]] = @FLOOR
            end
            if @map[next_point[0] - direction[0]][next_point[1]] == @WALL
                @map[next_point[0] - direction[0]][next_point[1]] = @FLOOR
            end
            if @map[next_point[0]][next_point[1]] == @WALL
                @map[next_point[0]][next_point[1]] = @FLOOR
            end

            current_point = next_point
        end
    end

    def get_tunnel_direction(point1, point2)
        if point1[0] < point2[0]
            horizontal_direction = 1
        elsif point1[0] > point2[0]
            horizontal_direction = -1
        else
            horizontal_direction = 0
        end

        if point1[1] < point2[1]
            vertical_direction = 1
        elsif point1[1] > point2[1]
            vertical_direction = -1
        else
            vertical_direction = 0
        end

        return [horizontal_direction, vertical_direction]
    end

    def stop_drawing(current_point, next_point, center_point, direction)
        if @disjoinset.find(next_point) == @disjoinset.find(center_point) && @map[next_point[0]][next_point[1] - direction[1]] == @FLOOR && @map[next_point[0] - direction[0]][next_point[1]] == @FLOOR
            return true
        end

        if @disjoinset.find(current_point) != @disjoinset.find(next_point) && @map[next_point[0]][next_point[1]] == @FLOOR && @map[next_point[0]][next_point[1] - direction[1]] == @FLOOR && @map[next_point[0] - direction[0]][next_point[1]] == @FLOOR
            return true
        else
            return false
        end
    end

    # Shortest path using breadth first search
    def shortest_path(start_coord, destination_coord)
        queue = Queue.new
        queue << [start_coord]
        seen = Set.new([start_coord])
        while queue
            begin
                path = queue.pop(non_block = true)
            rescue ThreadError
                return nil
            end
            x, y = path[-1]
            if [x, y] == destination_coord
                return path
            end
            for x2, y2 in [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]
                if (0 <= x2 && x2 < @map[0].length) && (0 <= y2 && y2 < @map.length) && (@map[y2][x2] != @WALL && @map[y2][x2] != @PERMANENT_WALL) && !seen.include?([x2, y2])
                    queue << (path + [[x2, y2]])
                    seen.add([x2, y2])
                end
            end
        end
    end

    def shortest_path_to_user(start_coord)
        queue = Queue.new
        queue << [start_coord]
        seen = Set.new([start_coord])
        while queue
            begin
                path = queue.pop(non_block = true)
            rescue ThreadError
                return nil
            end
            x, y = path[-1]
            if @map[y][x] == @USER
                return path
            end
            for x2, y2 in [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]
                if (0 <= x2 && x2 < @map[0].length) && (0 <= y2 && y2 < @map.length) && (@map[y2][x2] != @WALL && @map[y2][x2] != @PERMANENT_WALL) && !seen.include?([x2, y2])
                    queue << (path + [[x2, y2]])
                    seen.add([x2, y2])
                end
            end
        end
    end

    def nearest_driver(coord_from)
        queue = Queue.new
        queue << [coord_from]
        seen = Set.new([coord_from])
        while queue
            begin
                path = queue.pop(non_block = true)
            rescue ThreadError
                return nil
            end
            x, y = path[-1]
            if @map[y][x].instance_of?(Driver) && [x, y] != coord_from
                return { "coord" => [x, y], "route" => path, "object" => @map[y][x] }
            end
            for x2, y2 in [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]
                if (0 <= x2 && x2 < @map[0].length) && (0 <= y2 && y2 < @map.length) && (@map[y2][x2] != @WALL && @map[y2][x2] != @PERMANENT_WALL) && !seen.include?([x2, y2])
                    queue << (path + [[x2, y2]])
                    seen.add([x2, y2])
                end
            end
        end
    end

    def put_random(object)
        while true
            random_row = rand(1...@height - 1)
            random_column = rand(1...@width - 1)

            if @map[random_row][random_column] == @FLOOR
                @map[random_row][random_column] = object
                return [random_column, random_row]
            end
        end
    end

    def delete_driver(driver_coord)
        x, y = driver_coord
        @map[y][x] = @FLOOR
    end

    def check_drivers
        drivers.delete_if do |element|
            element["object"].suspended?
        end

        if drivers == 0
            map.put_driver_random(5)
        end
    end

    def show_map_with_path(path)
        map_temp = @map.map(&:clone)
        for x, y in path
            map_temp[y][x] = @PATH
        end
        for row in map_temp
            row_to_print = []
            for item in row
                if item == @FLOOR
                    row_to_print.push(" ")
                elsif item == @PATH
                    row_to_print.push(".")
                elsif item == @USER
                    row_to_print.push("\e[32m@\e[0m") # @ with green color
                elsif item.instance_of?(Driver)
                    row_to_print.push("D")
                elsif item.instance_of?(Restaurant)
                    row_to_print.push("R")
                elsif item == @WALL || item == @PERMANENT_WALL
                    row_to_print.push("#")
                else
                    row_to_print.push(" ")
                end
            end
            puts row_to_print.join(" ")
        end
    end
end
