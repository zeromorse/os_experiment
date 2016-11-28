require_relative 'pcb'

class Dispatcher

  def initialize(pcb_arr)
    @time = 0
    @pcb_arr = pcb_arr
    @block_queue = @pcb_arr.select { |p| p.start_block == @time }.each { |x| x.state = 'block' }
    @ready_queue = (@pcb_arr - @block_queue).sort { |x, y| y.priority <=> x.priority }
  end

  # 运行
  def run
    until @ready_queue.empty? && @block_queue.empty?
      print 'input enter to continue...'
      gets
      step
      @time += 1
    end
  end

  # 在每一个时间片上的操作
  def step
    mk_queue
    # 不安全,未处理ready_queue为空的情况
    @ready_queue[0].cpu_time += 1
    @ready_queue[0].all_time -= 1
    @ready_queue[0].state = 'run'
    output
    @pcb_arr.each { |x| x.change_priority }
    if @ready_queue[0].all_time == 0
      @ready_queue[0].state = 'finish'
      @ready_queue.delete_at 0
    else
      @ready_queue[0].state = 'ready'
    end
  end


  def output
    puts "RUNNING PROG: #{@ready_queue[0].id}"
    puts "READY-QUEUE: #{@ready_queue[1..-1].map { |x| '->' + x.id.to_s }.join}"
    puts "BLOCK-QUEUE: #{@block_queue.map { |x| '->' + x.id.to_s }.join}"
    puts '--------------------------------------------------'
    out_part 'ID          ', :id
    out_part 'PRIORITY    ', :priority
    out_part 'CPUTIME     ', :cpu_time
    out_part 'ALLTIME     ', :all_time
    out_part 'STARTBLOCK  ', :start_block
    out_part 'BLOCKTIME   ', :block_time
    puts 'STATE       ' + @pcb_arr.map { |x| x.state.to_s + "\t" }.join
    puts '==================================================='
  end

  # 部分输出
  def out_part(prefix, sym)
    puts prefix + @pcb_arr.map { |x| x.send(sym).to_s + "\t\t" }.join
  end

  # 制作阻塞队列和就绪队列
  def mk_queue
    new_block = @ready_queue.select { |x| x.start_block == @time }.each { |x| x.state = 'block' }
    new_ready = @block_queue.select { |x| x.start_block + x.block_time == @time - 1 }.each { |x| x.state = 'ready' }
    @ready_queue = @ready_queue - new_block + new_ready
    @block_queue = @block_queue - new_ready + new_block
    @ready_queue.sort! { |x, y| y.priority <=> x.priority }
  end

  private :step, :mk_queue, :output, :out_part
end