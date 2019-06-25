$:.unshift(File.dirname(__FILE__))

# External dependency
require "slop"
require "toml"

require "goeat/version"
require "goeat/map"
require "goeat/interface"

# Change this to adjust the map wall density
WALL_DENSITY = 0.40 # 0.40 for 40%

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
        map.put_restaurant_random(5)
        interface = Interface.new(map)
        interface.show_menu
        #m = Map.new(20, 20, WALL_DENSITY)
        #m.generate
        #puts "putting random driver"
        #m.puts_object_random(m.GOJEK_DRIVER, 4)
        #from = m.GOJEK_DRIVER_L[0]
        #to = m.nearest(m.GOJEK_DRIVER_L[0], m.GOJEK_DRIVER)
        #m.draw_path(m.shortest_path(from, to))
        #puts "done"
        #m.print_map
    elsif arguments_length == 1
        filename = opts.arguments[0]
        if File.file?(filename)
            begin
                #data = TOML.load_file(filename)
                #m = Map.new(20, 20, WALL_DENSITY)
                #m.from(data["map"])
                #m.print_map
            rescue NoMethodError
                puts "File format might be error"
            end
        end
    elsif arguments_length == 3
        map = Map.new(arguments[0].to_i, arguments[0].to_i, WALL_DENSITY)
        map.generate
        user_coord = [arguments[1].to_i, arguments[2].to_i]
        map.put_user(user_coord)
        map.put_driver_random(5)
        map.put_restaurant_random(5)
        interface = Interface.new(map)
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
