require_relative 'block'

class FFMemoryManager
  attr_reader :occupancies, :recycles

  def initialize(space, tasks)
    # 初始化内存分区
    init_block = Block.new space
    init_block.addr = 0
    @occupancies = [] # 占用空间列表初始化
    @recycles = [init_block] #回收列表初始化
    @tasks = tasks # 进程块初始化
    @counter = 0 # 记录执行命令的条数
  end

  # 执行命令 格式 task1 alloc/free
  # @return 命令的解释
  def execute(cmd)
    temp = cmd.split
    index = temp[0][-1].to_i
    space = @tasks[index].space
    @counter += 1
    case temp[1]
      when 'free'
        free @tasks[index]
        "#{@counter}.作业#{index}释放空间#{space}"
      when 'alloc'
        alloc @tasks[index]
        "#{@counter}.作业#{index}申请空间#{space}"
      else
        '命令输入有误...'
    end
  end

  private
  # 分配内存
  def alloc(task)
    recycle = @recycles.sort_by! { |b| b.addr }.detect { |b| b.space >= task.space } # ff
    if recycle.nil?
      raise '没有足够的内存可供分配!'
    else
      # 保留小分区
      if recycle.space > task.space
        new_recycle = Block.new(recycle.space-task.space)
        new_recycle.addr = recycle.addr + task.space
        @recycles << new_recycle
      end
      # 回收列表减少,占用空间列表增加
      @recycles.delete recycle
      task.addr = recycle.addr
      @occupancies << task
      show_block
    end
  end

  # 释放内存
  def free(task)
    # 放入回收内存列表
    marge_free task
    # 在占用空间列表删除该对象
    @occupancies.delete task
    show_block
  end

  # 加入并合并空闲分区
  def marge_free(task)
    @recycles.each do |x|
      if x.addr + x.space == task.addr
        x.space += task.space
        @recycles.each do |z|
          if x.addr + x.space == z.addr
            x.space += z.space
            @recycles.reject! { |a| a.addr == z.addr }
            break
          end
        end
        return
      elsif task.addr + task.space == x.addr
        task.space += x.space
        @recycles.reject! { |a| a.addr == x.addr }
        over_task = false
        @recycles.each do |z|
          if z.addr + z.space == task.addr
            z.space += task.space
            over_task = true
            break
          end
        end
        @recycles << task unless over_task
        return
      end
    end
    @recycles << task
  end

  # 显示内存块情况
  def show_block
    puts '空闲内存块'
    unless @recycles.nil?
      @recycles.each do |r|
        puts r.to_s
      end
    end
    puts '-------------------------------------'
    puts '任务内存块'
    unless @occupancies.nil?
      @occupancies.each do |t|
        puts t.to_s
      end
    end
    puts '====================================='
  end
end