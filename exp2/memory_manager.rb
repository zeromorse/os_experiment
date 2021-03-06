require_relative 'block'

class MemoryManager

  def initialize(space)
    # 初始化内存分区
    init_block = Block.new space
    init_block.addr = 0
    @tasks = [] # 任务列表初始化
    @recycles = [init_block] #回收列表初始化
  end

  # 子类实现
  def select(task)
  end

  # 分配内存
  def alloc(task)
    recycle = select task
    if recycle.nil?
      raise '没有足够的内存可供分配!'
    else
      # 保留小分区
      if recycle.space > task.space
        new_recycle = Block.new(recycle.space-task.space)
        new_recycle.addr = recycle.addr + task.space
        @recycles << new_recycle
      end
      # 回收列表减少,任务列表增加
      @recycles.delete recycle
      task.addr = recycle.addr
      @tasks << task
      show_block
    end
  end

  # 释放内存
  def free(task)
    # 放入回收内存列表
    marge_free task
    # 在任务列表删除该对象
    @tasks.delete task
    show_block
  end

  private
  # 加入合并空闲分区
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

  # 显示空闲区链情况
  def show_block
    puts '空闲内存块'
    unless @recycles.nil?
      @recycles.each do |r|
        puts r.to_s
      end
    end
    puts '-------------------------------------'
    puts '任务内存块'
    unless @tasks.nil?
      @tasks.each do |t|
        puts t.to_s
      end
    end
    puts '====================================='
    gets
  end
end