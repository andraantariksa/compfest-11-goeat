require "spec_helper"

RSpec.describe Driver do
    driver_obj = Driver.new

    it "will have an initial rating 0.0" do
        expect(driver_obj.rating).to eq(0.0)
    end

    it "will be suspended if he has a rating below 3.0" do
        driver_obj.rate(2.0)
        expect(driver_obj.suspended?).to eq(true)
    end

    it "has a correct plate according to /[A-Z]{1,2}[1-9]{4,5}[A-Z]{1,2}/ regex" do
        expect(driver_obj.plate).to match(/[A-Z]{1,2}[1-9]{4,5}[A-Z]{1,2}/)
    end

    it "has two words name" do
        expect(driver_obj.name).to match(/[A-Za-z]{3,}\s+[A-Za-z]{3,}/)
    end
end
