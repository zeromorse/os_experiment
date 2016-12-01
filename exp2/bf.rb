require_relative 'memory_manager'

class BFMemoryManager < MemoryManager
  def select(task)
    @recycles.select { |b| b.space >= task.space }.max_by { |b| b.space }
  end
end

tasks = Block.mk_blocks 130, 60, 100, 200, 140, 60, 50
manager = BFMemoryManager.new 640

manager.alloc tasks[0]
manager.alloc tasks[1]
manager.alloc tasks[2]
manager.free tasks[1]
manager.alloc tasks[3]
manager.free tasks[2]
manager.free tasks[0]
manager.alloc tasks[4]
manager.alloc tasks[5]
manager.alloc tasks[6]
manager.free tasks[5]