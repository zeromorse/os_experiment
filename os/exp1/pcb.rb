class Pcb
  attr_accessor :priority, :all_time, :block_time, :state, :cpu_time, :start_block, :id
  @@count = 0

  def initialize(priority, all_time, start_block, block_time)
    @id = @@count
    @@count += 1
    @priority = priority
    @cpu_time = 0
    @all_time = all_time
    @start_block = start_block
    @block_time = block_time
    @state = 'ready' # 'run','ready','block','finish'
  end

  # 改变优先级
  def change_priority
    case state
      when 'run'
        @priority -= 3
      when 'ready'
        @priority += 1
    end
  end
end


