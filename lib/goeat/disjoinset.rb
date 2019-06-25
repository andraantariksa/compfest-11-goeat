
# A simple disjoint set ADT which uses path compression on finds to speed things up
class DisjointSet
    attr_reader :items

    def initialize
        @size = 0
        @items = {}
    end

    def union(root1, root2)
        if @items[root2] < @items[root1]
            @items[root1] = root2
        else
            if @items[root1] == @items[root2]
                @items[root1] -= 1
            end
            @items[root2] = root1
        end
    end

    def find(key)
        while true
            if @items.key?(key)
                if @items[key].is_a?(Integer)
                    if @items[key] <= 0
                        return key
                    end
                end
                key = @items[key]
            else
                @items[key] = -1
                return key
            end
        end
    end

    def split_sets
        sets = {}
        j = 0
        for j in @items.keys()
            root = find(j)
            if root.is_a?(Integer)
                if root <= 0
                    next
                end
            end
            if sets.key?(root)
                list = sets[root]
                list.push(j)
                sets[root] = list
            else
                sets[root] = [j]
            end

        end
        sets
    end
end
