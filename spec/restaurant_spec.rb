require "spec_helper"

RSpec.describe Restaurant do
    restaurant_obj = Restaurant.new

    it "have 3 minimum number of menus" do
        expect(restaurant_obj.menu.length).to be >= 3
    end

    it "has two words name" do
        expect(restaurant_obj.name).to match(/\w+\s+\w+/)
    end
end
