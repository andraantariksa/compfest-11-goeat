require "time"
require_relative "map"

class Interface
    def initialize(map, driver_cost_per_unit)
        @map_obj = map
        @driver_cost_per_unit = driver_cost_per_unit
        @order_history = []
    end

    # Clear the console screen
    def clear
        puts "\n" * 40
    end

    # Show main menu
    def show_menu
        # Error message
        err_message = ""
        while true
            clear
            print "   _____    ____             ______              _______ \n  \/ ____|  \/ __ \\           |  ____|     \/\\     |__   __|\n | |  __  | |  | |  ______  | |__       \/  \\       | |   \n | | |_ | | |  | | |______| |  __|     \/ \/\\ \\      | |   \n | |__| | | |__| |          | |____   \/ ____ \\     | |   \n  \\_____|  \\____\/           |______| \/_\/    \\_\\    |_|   "
            small_line_separator
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

            input = take_input

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
            when 3
                show_orders_history
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

    # Show available restaurant
    def show_restaurant
        err_message = ""
        while true
            clear
            puts "Available restaurant to order:"
            @map_obj.restaurants.each_with_index do |restaurant, idx|
                restaurant_obj = restaurant["object"]
                puts "[#{idx + 1}] #{restaurant_obj.name}"
            end
            puts "[0] Quit"
            small_line_separator

            if err_message != ""
                puts err_message
            end

            input = take_input

            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end
            if input_number == 0
                return
            elsif 0 < input_number && input_number <= @map_obj.restaurants.length
                clear
                restaurant = @map_obj.restaurants[input_number - 1]
                show_restaurant_menu(restaurant)
            end
        end

    end

    def deliver(restaurant, invoice, invoice_toml, driver, path_to_user)
        clear
        err_message = ""

        driver_obj = driver["object"]
        restaurant_obj = restaurant["object"]

        invoice += "\n\n"
        invoice += "Driver info\n"
        invoice += "=" * 53 + "\n"
        invoice += "Name: #{driver_obj.name}\n"
        invoice += "Plate: #{driver_obj.plate}\n"
        invoice += "=" * 53 + "\n"

        puts "We have got you a driver!"
        small_line_separator
        puts "=" * 53
        puts "Driver information"
        puts "=" * 53
        puts driver_obj.name
        puts driver_obj.plate
        if driver_obj.first_time
            puts "It's his first time of driving with Go-Eat!"
        else
            puts "Rating #{driver_obj.rating}"
        end
        puts "=" * 53
        puts ""
        puts "The driver will deliver the food to your place, please wait"
        small_line_separator
        hold

        clear
        @map_obj.show_map_with_path(driver["route"].slice(1...-1))
        hold

        clear
        @map_obj.delete_driver(driver["coord"])
        @map_obj.show_map_with_path(path_to_user.slice(1...-1))
        hold

        clear
        puts "Yippee!"
        puts "Your order has arrived!"
        hold

        while true
            clear
            puts "You can give the driver a rating star, you can give them 1 to 5."
            puts "[1] I hate it"
            puts "[2] I didn't like it"
            puts "[3] It was OK"
            puts "[4] I liked it"
            puts "[5] I loved it"
            puts "How was the driver?"
            small_line_separator
            if err_message != ""
                puts err_message
            end

            input = take_input

            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end
            if 1 <= input_number && input_number <= 5
                driver_obj.rate(input_number.to_f)
                # If the driver not suspended, he can stil work as a driver
                if !driver_obj.suspended?
                    # The driver moves to another place on the map aka mangkal
                    new_driver_coord = @map_obj.put_random(driver_obj)
                    driver["coord"] = new_driver_coord
                    @map_obj.drivers.push(driver)
                end
                if @map_obj.drivers.length == 0
                    @map_obj.put_driver_random(5)
                end
                break
            else
                err_message = "You can only rate the driver between 1 to 5."
            end
        end

        time = Time.now

        @order_history.push({
                                "time" => time,
                                "invoice" => invoice
        })

        file = File.open("tx_log/tx-#{time.hour}-#{time.min}-#{time.sec}-#{time.day}-#{time.month}-#{time.year}.toml", "w")
        file.puts invoice_toml
        file.close

        true
    end

    def checkout(restaurant, cart)
        restaurant_obj = restaurant["object"]
        driver = @map_obj.nearest_driver(restaurant["coord"])
        path_to_user = @map_obj.shortest_path_to_user(restaurant["coord"])

        driver_cost_to_restaurant = (driver["route"].length - 1) * @driver_cost_per_unit
        driver_cost_to_customer =  (path_to_user.length - 1) * @driver_cost_per_unit
        distance_total = (driver["route"].length - 1) + (path_to_user.length - 1)

        err_message = ""

        while true
            clear

            invoice = generate_invoice(restaurant, cart, distance_total, @driver_cost_per_unit, driver_cost_to_restaurant + driver_cost_to_customer)
            invoice_toml = generate_invoice_toml(restaurant, cart, driver, distance_total, @driver_cost_per_unit, driver_cost_to_restaurant + driver_cost_to_customer)
            puts invoice

            small_line_separator
            puts "Are you sure you want to purchase this? (yes/no)"
            if err_message != ""
                puts err_message
            end

            input = take_input

            case input
            when "yes"
                return deliver(restaurant, invoice, invoice_toml, driver, path_to_user)
            when "no"
                return false
            else
                err_message = "Invalid input"
            end
        end
    end

    def generate_invoice_toml(restaurant, cart, driver, distance_total, driver_cost_per_unit, deliver_cost_total)
        restaurant_obj = restaurant["object"]
        driver_obj = driver["object"]

        output_toml = {
            "restaurant_name" => restaurant_obj.name,
            "restaurant_menu" => [],
            "driver_cost_per_unit" => driver_cost_per_unit,
            "deliver_cost_total" => deliver_cost_total,
        }
        total_price = 0
        restaurant_obj.menu.each_with_index do |menu_item, idx|
            total_price += menu_item["price"] * cart[idx]
            output_toml["restaurant_menu"].push({
                                                    "name" => menu_item["name"],
                                                    "price" => menu_item["price"],
                                                    "quantity" => cart[idx],
                                                    "subtotal" => menu_item["price"] * cart[idx]
            })
        end
        output_toml["grand_total"] = total_price + deliver_cost_total
        output_toml["driver"] = {
            "name" => driver_obj.name,
            "plate" => driver_obj.plate
        }
        TOML::Generator.new(output_toml).body
    end

    def generate_invoice(restaurant, cart, distance_total, driver_cost_per_unit, deliver_cost_total)
        restaurant_obj = restaurant["object"]

        invoice = ""
        invoice += "#{restaurant_obj.name}'s Invoice\n"
        invoice += "=" * 53 + "\n"
        invoice += "%-5s %-20s   %-6s   %-3s %-8s\n" % ["No.", "Name", "Price", "Qty", "Subtotal"]
        invoice += "=" * 53 + "\n"
        total_price = 0
        restaurant_obj.menu.each_with_index do |menu_item, idx|
            total_price += cart[idx] * menu_item["price"]
            invoice += "[%2d] %-20s - %6d - %3d - %10d\n" % [idx + 1, menu_item["name"], menu_item["price"], cart[idx], cart[idx] * menu_item["price"]]
        end
        invoice += "=" * 53 + "\n"
        invoice += "Total food price %36d\n" % [total_price]
        invoice += "=" * 53 + "\n"
        invoice += "Driver cost %28s   %10d\n" % ["#{distance_total} unit * #{driver_cost_per_unit}", deliver_cost_total]
        invoice += "=" * 53 + "\n"
        invoice += "Grand total %41d\n" % [total_price + deliver_cost_total]
        invoice += "=" * 53
        invoice
    end

    def show_restaurant_menu(restaurant)
        restaurant_obj = restaurant["object"]
        cart = (0...restaurant_obj.menu.length).map { 0 }
        err_message = ""
        while true
            clear

            puts "#{restaurant_obj.name}'s Menu"
            puts "=" * 53
            printf("%-5s %-20s   %-6s   %-3s %-8s\n", "No.", "Name", "Price", "Qty", "Subtotal")
            puts "=" * 53
            total_price = 0
            restaurant_obj.menu.each_with_index do |menu_item, idx|
                total_price += cart[idx] * menu_item["price"]
                printf("[%2d] %-20s - %6d - %3d - %10d\n", idx + 1, menu_item["name"], menu_item["price"], cart[idx], cart[idx] * menu_item["price"])
            end
            puts "[ 0] Cancel"
            puts "=" * 53
            printf("Total %47d\n", total_price)
            puts "=" * 53

            small_line_separator
            puts "Type the number to add to cart. Type the number with minus (-) to decrease it. Type \"checkout\" to checkout. You can also type %menu number quantity%, e.g \"1 5\" (5 items for menu number 1), \"1 -5\" (reduce 5 items for menu number 1)."
            if err_message != ""
                puts err_message
            end

            input = take_input

            if input == "checkout"
                if !cart.any? { |element| element > 0 }
                    err_message = "You haven't choose anything"
                    next
                end
                return checkout(restaurant, cart)
            elsif input.match(/(\d+)\s+(-?\d+)/)
                menu_number, quantity = input.match(/(\d+)\s+(-?\d+)/).captures
                begin
                    menu_number = Integer(menu_number)
                    quantity = Integer(quantity)
                rescue ArgumentError
                    err_message = "Invalid input"
                    next
                end
                cart[menu_number - 1] += quantity
                if cart[menu_number - 1] < 0
                    cart[menu_number - 1] = 0
                end
                next
            end

            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end
            begin
                if input_number < 0
                    cart[(input_number * -1) - 1] -= 1
                elsif input_number > 0
                    cart[input_number - 1] += 1
                else
                    return
                end
            rescue NoMethodError
                err_message = "Item not available"
            end
        end
    end

    def show_how_to_use
        clear
        puts """Thanks for using Go-Eat! Order your food now – all you need to do is just order the food from the restaurant that are available on the apps.

HOW TO USE GO-EAT

1. Select your restaurant – Select your favorite restaurant
2. See the menu and your food cost – We’ll let you know how much the food costs, then ORDER GO-EAT when you’re have done
3. Pay in cash – Currently, Go-Eat only accept cash payment
4. Take the food – Get ready as the nearest driver-partner makes their way to you, then you can take the food that you have already ordered
4. Enjoy the food

MAP LEGEND
R – Restaurant
D – Driver
@ – You"""
        hold
    end

    def show_map
        clear
        @map_obj.show_map
        hold
    end

    # Hold the user until he press return button
    def hold
        puts "\nPress RETURN to continue"
        STDIN.gets
    end

    def small_line_separator
        puts "\n" * 3
    end

    def show_orders_history
        err_message = ""

        while true
            clear
            @order_history.reverse.each_with_index do |element, idx|
                history_time = element["time"]
                idx_updated = @order_history.length - idx
                printf("[%3d] Order #%d\n", idx_updated, idx_updated)
            end
            puts "[  0] Quit"
            small_line_separator
            if err_message != ""
                puts err_message
            end

            input = take_input

            begin
                input_number = Integer(input)
            rescue ArgumentError
                err_message = "Invalid input"
                next
            end

            if input_number == 0
                return
            end

            clear
            begin
                puts @order_history[@order_history.length - input_number - 1]["invoice"]
                hold
            rescue Errno::EISDIR
                err_message = "Invalid transaction: transaction not exists"
            end
        end
    end

    def take_input
        print "> "
        input = STDIN.gets
        input.downcase!
        input.strip!
        input
    end
end
