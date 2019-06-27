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
    def self.run
        opts = Slop.parse do |options|
            options.banner =  "Usage: ruby gofood.rb [options] [| file | map_side_size user_x_position user_y_position] ..."
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

        # With no argument
        if arguments_length == 0
            map = Map.new(width: 20, height: 20, wall_percentage: WALL_DENSITY)
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

            # With one file argument
        elsif arguments_length == 1
            file_name = opts.arguments[0]
            if File.file?(file_name)
                begin
                    map = Map.new(file_name: file_name)
                rescue RunTime => err
                    puts err.message
                    exit
                end
                interface = Interface.new(map, DRIVER_COST_PER_UNIT_DISTANCE)
                begin
                    interface.show_menu
                rescue Interrupt
                    interface.quit
                end
            else
                puts "File not found"
                exit
            end

            # With three argument
            # 1. Map side size
            # 2. User x position
            # 3. User y position
        elsif arguments_length == 3
            map_side_size = arguments[0].to_i
            map = Map.new(width: map_side_size, height: map_side_size, wall_percentage: WALL_DENSITY)
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
end
