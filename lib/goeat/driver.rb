# Driver name list
DRIVER_FIRST_NAME = ["Andra", "Indra", "Felix", "Adi", "Aria", "Rizki", "Arief", "Angga", "Dimas", "Dani", "Gilang", "Agus", "Abdul", "Adit", "Agung"]
DRIVER_LAST_NAME = ["Baskoro", "Kurniawan", "Mahendra", "Nugraha", "Nugroho", "Permana", "Pradita", "Prasetyo", "Priyanto", "Purnama", "Raharjo", "Setiawan", "Saputra", "Sanjaya", "Sunarmo"]
DRIVER_USED_NAME = []
DRIVER_MAXIMUM_NAME_POSSIBILITY = DRIVER_FIRST_NAME.length * DRIVER_LAST_NAME.length
DRIVER_USED_PLATE = []

class Driver
    attr_accessor :name, :rating, :plate, :first_time

    def initialize(name=nil, plate=nil, rating=nil, first_time=nil)
        if name == nil
            @rating = 0.0
            @first_time = true

            # Generate a unique name
            if DRIVER_USED_NAME.length >= DRIVER_MAXIMUM_NAME_POSSIBILITY
                raise "Driver name limit"
            end
            while true
                generated_name = DRIVER_FIRST_NAME.sample + " " + DRIVER_LAST_NAME.sample
                if !DRIVER_USED_NAME.include?(generated_name)
                    @name = generated_name
                    DRIVER_USED_NAME.push(generated_name)
                    break
                end
            end


            # Generate a unique plate
            while true
                plate_prefix = (1..rand(1..2)).map { ('A'..'Z').to_a[rand(26)] }.join
                plate_infix = (1..rand(4..5)).map { ('1'..'9').to_a[rand(9)] }.join
                plate_suffix = (1..rand(1..2)).map { ('A'..'Z').to_a[rand(26)] }.join
                if !DRIVER_USED_PLATE.include?(generated_name)
                    @plate = "#{plate_prefix}#{plate_infix}#{plate_suffix}"
                    DRIVER_USED_PLATE.push(generated_name)
                    break
                end
            end

        end
    end

    def rate(rating)
        if @first_time
            @first_time = false
            @rating = rating
        else
            @rating = (rating + @rating) / 2.0
        end
        suspended?
    end

    def suspended?
        @rating < 3.0
    end
end
