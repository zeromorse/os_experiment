require_relative 'dispatcher'

class FifoDispatcher < Dispatcher
  def initialize
    super
    @stay_counters = Array.new(4, 0)
  end

  private
  def embed(index)
    @stay_counters.map! { |i| i+1 }
  end

  def swap(it_index)
    oldest = 0
    @stay_counters.each_with_index do |counter, index|
      oldest = index if counter > @stay_counters[oldest]
    end
    @blocks[oldest] = get_page @instructs[it_index]
    @stay_counters[oldest] = 0
  end
end

dispatcher = FifoDispatcher.new
dispatcher.run