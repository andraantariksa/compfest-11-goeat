require "spec_helper"

RSpec.describe Map do
    map_obj = Map.new(width: 20, height: 20, wall_percentage: WALL_DENSITY)
    map_obj.generate

    map_loaded = Map.new(file_name: "spec/example.toml")

    it "has only one connected cave" do
        expect(map_obj.populate_caves.length).to be == 1
    end

    it "do the right shortest path" do
        expect(map_loaded.shortest_path([4, 4], [17, 4])).to eq([[4, 4], [4, 5], [4, 6], [4, 7], [4, 8], [5, 8], [5, 9], [6, 9], [7, 9], [8, 9], [9, 9], [10, 9], [11, 9], [12, 9], [13, 9], [14, 9], [15, 9], [16, 9], [17, 9], [17, 8], [17, 7], [17, 6], [17, 5], [17, 4]])
    end

    it "will raise an error if you're trying to load a file has more than 1 cave room" do
        expect{ Map.new(file_name: "spec/example_error.toml") }.to raise_error(RuntimeError)
    end
end
