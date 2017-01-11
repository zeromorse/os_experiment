class Block
  attr_accessor :addr, :space

  def initialize(space)
    @space = space
  end

  # 创建多个进程控制块
  def Block.mk_blocks(*spaces)
    blocks = []
    spaces.each { |s| blocks << Block.new(s) }
    blocks
  end

  def to_s
    "首地址:#{@addr},内存空间:#{@space}"
  end
end