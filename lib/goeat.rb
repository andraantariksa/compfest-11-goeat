$:.unshift(File.dirname(__FILE__))

# External dependency
require "slop"
require "toml"

require "goeat/version"
require "goeat/map"
require "goeat/interface"

# Change this to adjust the map wall density
WALL_DENSITY = 0.40 # 0.40 for 40%
DRIVER_COST_PER_UNIT_DISTANCE = 300

module Goeat
    opts = Slop.parse do |options|
        options.banner =  "Usage: ruby gofood.rb [options] [file | map_side_size user_x_position user_y_position] ..."
        options.separator ""
        options.separator "Other options:"
        options.on "-h", "--help", "Show this help text" do
            puts options
            exit
        end
        options.on "-v", "--version", "Show version" do
            puts VERSION
            exit
        end
    end

    arguments = opts.arguments
    arguments_length = arguments.length
    if arguments_length == 0
        map = Map.new(20, 20, WALL_DENSITY)
        map.generate
        map.put_user([10, 10])
        map.put_driver_random(5)
        map.put_restaurant_random(3)
        interface = Interface.new(map, DRIVER_COST_PER_UNIT_DISTANCE)
        begin
            interface.show_menu
        rescue Interrupt
            interface.quit
        end
    elsif arguments_length == 1
        file_name = opts.arguments[0]
        if File.file?(file_name)
            begin
                file_data = TOML.load_file(file_name)
            rescue NoMethodError
                puts "File format might be error"
                exit
            end
            if file_data["map"].length < 20
                puts "Invalid file: The map is too small"
                exit
            else
                if file_data["map"][0].length < 20
                    puts "Invalid file: The map is too small"
                    exit
                end
            end
            map = Map.new(file_data["map"][0].length, file_data["map"].length, WALL_DENSITY)
            interface = Interface.new(map, DRIVER_COST_PER_UNIT_DISTANCE)
            interface.from_data(file_data)
            begin
                interface.show_menu
            rescue Interrupt
                interface.quit
            end
        end
    elsif arguments_length == 3
        map_side_size = arguments[0].to_i
        map = Map.new(map_side_size, map_side_size, WALL_DENSITY)
        map.generate
        user_coord = [arguments[1].to_i, arguments[2].to_i]
        user_x_position, user_y_position = user_coord
        begin
            map.put_user(user_coord)
        rescue RangeError
            puts "Invalid input: Invalid user location"
            exit
        end
        map.put_driver_random(5)
        map.put_restaurant_random(3)
        interface = Interface.new(map, DRIVER_COST_PER_UNIT_DISTANCE)
        begin
            interface.show_menu
        rescue Interrupt
            interface.quit
        end
    else
        puts "Argument(s)es not exist"
        puts ""
        puts opts
    end
end
