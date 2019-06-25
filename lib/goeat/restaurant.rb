# Driver name list
RESTAURANT_FIRST_NAME = ["Selera", "Mc", "Berkah", "Barokah", "Warteg"]
RESTAURANT_LAST_NAME = ["Bunda", "Bahari", "Jaya", "Nusantara", "Sederhana", "88", "Lezat"]
RESTAURANT_USED_NAME = []
RESTAURANT_MAXIMUM_NAME_POSSIBILITY = RESTAURANT_FIRST_NAME.length * RESTAURANT_LAST_NAME.length
RESTAURANT_MENU_NAME = ["Ayam Goreng", "Ayam Bakar", "Gurame Bakar", "Nasi Bakar", "Burger", "Nasi Goreng", "Mie Goreng", "Mie Rebus", "Kwetiaw", "Telur Balado"]

class Restaurant
    attr_reader :name, :menu

    def initialize
        # Generate a unique name
        if RESTAURANT_USED_NAME.length >= RESTAURANT_MAXIMUM_NAME_POSSIBILITY
            raise "Restaurant name limit"
        end
        while true
            generated_name = RESTAURANT_FIRST_NAME.sample + " " + RESTAURANT_LAST_NAME.sample
            if !RESTAURANT_USED_NAME.include?(generated_name)
                RESTAURANT_USED_NAME.push(generated_name)
                break
            end
        end
        @name = generated_name

        # Generate random menu
        @menu = []
        # Each restaurant has 3 - 8 menus
        total_menu = rand(3..8)
        for menu_name in RESTAURANT_MENU_NAME.sample(total_menu)
            menu_item = {
                "name" => menu_name,
                # Random price ranging from 10000 to 50000
                "price" => rand(10..50) * 1000
            }
            @menu.push(menu_item)
        end
    end
end
