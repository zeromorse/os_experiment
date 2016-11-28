require_relative 'dispatcher'

class OptDispatcher < Dispatcher
  def initialize
    super
  end

  private
  def swap(it_index)
    next_use_distances = Array.new(4,0)
    farthest = 0
    @blocks.each_with_index do |page, i|
      @instructs[(it_index+1)..-1].each do |it|
        if get_page(it) != page
          next_use_distances[i] += 1
        else
          break
        end
      end
      farthest = i if next_use_distances[i] > next_use_distances[farthest]
    end
    @blocks[farthest] = get_page @instructs[it_index]
  end
end

dispatcher = OptDispatcher.new
dispatcher.run