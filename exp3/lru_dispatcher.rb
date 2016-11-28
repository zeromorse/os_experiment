require_relative 'dispatcher'

class LruDispatcher < Dispatcher
  def initialize
    super
    @last_used_times = Array.new(4, 0)
  end

  private
  def swap(it_index)
    oldest = 0
    @last_used_times.each_with_index do |time, index|
      oldest = index if time < @last_used_times[oldest]
    end
    @blocks[oldest] = get_page @instructs[it_index]
  end

  def embed(index)
    page = get_page @instructs[index]
    @blocks.each_with_index do |value, i|
      if page == value
        @last_used_times[i] = index
        break
      end
    end
  end
end

dispatcher = LruDispatcher.new
dispatcher.run