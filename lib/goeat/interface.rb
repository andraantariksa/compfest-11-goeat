require_relative "map"

class Interface
    def initialize(map)
        @map_obj = map
    end

    # Clear the console screen
    def clear
        puts "\n" * 40
    end

    def show_menu
        # Error message
        err_message = ""
        while true
            clear
            puts "Available command:"
            puts "[1] Show Map"
            puts "[2] Order Food"
            puts "[3] View Order History"
            puts "[4] How to Use"
            puts "[0] Quit"
            small_line_separator
            if err_message != ""
                puts err_message
            end

            print "> "
            input = STDIN.gets
            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end

            case input_number
            when 1
                show_map
            when 2
                show_restaurant
=begin
                clear
                for restaurant in @map_obj.restaurants
                    puts "=" * 30
                    restaurant_obj = restaurant["object"]
                    restaurant_obj.print_menu
                    puts "=" * 30
                end
                STDIN.gets
=end
            when 3
                puts ""
            when 4
                show_how_to_use
            when 0
                quit
            else
                err_message = "Command \"#{input_number}\" is not available"
            end
        end
    end

    def quit
        clear
        puts "Bye :) !"
        exit
    end

    def show_restaurant
        err_message = ""
        while true
            clear
            puts "Available restaurant to order:"
            @map_obj.restaurants.each_with_index do |restaurant, index|
                restaurant_obj = restaurant["object"]
                puts "[#{index + 1}] #{restaurant_obj.name}"
            end
            puts "[0] Quit"
            small_line_separator

            if err_message != ""
                puts err_message
            end
            print "> "
            input = STDIN.gets
            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end
            if input_number == 0
                return
            elsif 0 < input_number && input_number < @map_obj.restaurants.length
                clear
                restaurant_obj = @map_obj.restaurants[input_number - 1]["object"]
                show_restaurant_menu(restaurant_obj)
            end
        end

    end

    def show_restaurant_menu(restaurant_obj)
        cart = (0...restaurant_obj.menu.length).map { 0 }
        err_message = ""
        while true
            clear
            puts "#{restaurant_obj.name}'s Menu"
            puts "=" * 30
            restaurant_obj.menu.each_with_index do |menu_item, index|
                puts "[#{index + 1}] #{menu_item["name"]} - #{menu_item["price"]} - #{cart[index]}"
            end
            puts "[0] Cancel"
            puts "Total: #{}"
            small_line_separator
            if err_message != ""
                puts err_message
            end

            print "> "
            input = STDIN.gets
            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end
            begin
                cart[input_number - 1] += 1
            rescue NoMethodError
                err_message = "Item not available"
            end
        end
    end

    def show_how_to_use
        clear
        puts "Blah"
        hold
    end

    def show_map
        clear
        @map_obj.show_map
        hold
    end

    def hold
        puts "\nPress RETURN to continue"
        STDIN.gets
    end

    def small_line_separator
        puts "\n" * 3
    end
end
