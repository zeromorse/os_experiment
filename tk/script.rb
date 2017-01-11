require 'tk'
require_relative 'block'
require_relative 'ff_memory_manager'

BASE = 640 # 内存基础大小
tasks = Block.mk_blocks(130, 60, 100, 200, 140, 60, 50) # 初始化各任务块
Manager = FFMemoryManager.new(BASE, tasks) # 创建内存管理器

# 建立根面板
root = TkRoot.new { title '首次适应算法内存演示' }

# 初始化执行命令说明标签
hint = TkVariable.new # 提示字
HintLabel = TkLabel.new(root) do
  textvariable
  height 3
  font TkFont.new('times 14')
  pack('side' => 'top', 'padx' => '5', 'pady' => '5')
end
HintLabel['textvariable'] = hint
hint.value = '内存空间初始化完成'

# 初始化内存状态条说明标签
TkLabel.new(root) do
  text '内存状态如下'
  font TkFont.new('times 16 bold')
  pack('padx' => '10', 'pady' => '10')
end

# 初始化彩色内存使用条
MemoryCanvas = TkCanvas.new(root) { height 200 }

# 用于矩形定位的常量
INIT_UP = 10
INIT_LEFT = 10
HEIGHT = 150
TOTAL_WIDTH = 360

# 内存块图示区域, 初始化为空闲区域
Rects = [TkcRectangle.new(MemoryCanvas, INIT_LEFT, INIT_UP, TOTAL_WIDTH, INIT_UP + HEIGHT, 'fill' => 'grey')]

# 清空所有矩形块
def Rects.clear
  self.each_index { |i| self[i].delete }
end

# 内存大小到矩形大小的转换
def calc(value)
  value.to_f / BASE * TOTAL_WIDTH
end

# 绘制矩形块
def Rects.paint
  Manager.occupancies.each do |block|
    Rects << TkcRectangle.new(MemoryCanvas, calc(block.addr), INIT_UP, calc(block.addr + block.space), INIT_UP + HEIGHT, 'fill' => 'blue')
  end
  Manager.recycles.each do |block|
    Rects << TkcRectangle.new(MemoryCanvas, calc(block.addr), INIT_UP, calc(block.addr + block.space), INIT_UP + HEIGHT, 'fill' => 'grey')
  end
end

MemoryCanvas.pack # 压紧

# 初始化输入frame
inputFrame = TkFrame.new(root) do
  width 320
  height 70
  padx 10
  pady 10
  pack('side' => 'bottom')
end

# 初始化命令输入框(属于inputFrame)
inputText = TkText.new(inputFrame) do
  width 40
  height 1
  font TkFont.new('times 12 bold')
  pack('side' => 'left', 'padx' => '10', 'pady' => '10')
end

# 初始化指令确定框(属于inputFrame)
TkButton.new(inputFrame) do
  text '执行'
  state 'normal'
  cursor 'hand2'
  font TkFont.new('times 12 bold')
  foreground 'blue'
  activebackground 'yellow'
  relief 'groove'
  command (proc do
    hint.value = Manager.execute(inputText.value)
    Rects.clear
    Rects.paint
  end)
  pack('side' => 'right', 'padx' => '10', 'pady' => '10')
end

Tk.mainloop

=begin
task0 alloc
task1 alloc
task2 alloc
task1 free
task3 alloc
task2 free
task0 free
task4 alloc
task5 alloc
task6 alloc
task5 free
=end