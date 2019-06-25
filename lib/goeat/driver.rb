# Driver name list
DRIVER_FIRST_NAME = ["Andra", "Indra", "Felix", "Adi", "Aria", "Rizki", "Arief", "Angga", "Dimas", "Dani", "Gilang", "Agus", "Abdul", "Adit", "Agung"]
DRIVER_LAST_NAME = ["Baskoro", "Kurniawan", "Mahendra", "Nugraha", "Nugroho", "Permana", "Pradita", "Prasetyo", "Priyanto", "Purnama", "Raharjo", "Setiawan", "Saputra", "Sanjaya", "Sunarmo"]
DRIVER_USED_NAME = []
DRIVER_MAXIMUM_NAME_POSSIBILITY = DRIVER_FIRST_NAME.length * DRIVER_LAST_NAME.length

class Driver
    attr_reader :name, :rating

    def initialize
        @rating = 5.0

        # Generate a unique name
        if DRIVER_USED_NAME.length >= DRIVER_MAXIMUM_NAME_POSSIBILITY
            raise "Driver name limit"
        end
        while true
            generated_name = DRIVER_FIRST_NAME.sample + " " + DRIVER_LAST_NAME.sample
            if !DRIVER_USED_NAME.include?(generated_name)
                DRIVER_USED_NAME.push(generated_name)
                break
            end
        end
        @name = generated_name
    end

    def rate(rating)
        @rating = (rating + @rating) / 2.0
        suspended?
    end

    def suspended?
        @rating < 3.0
    end
end
