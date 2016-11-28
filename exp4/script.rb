class FAT # 文件分配表
  def initialize(length=32)
    @blocks = Array.new(length, '') # 拥有的物理块,长度为8的字符串
    @indices = Array.new(length) # 索引数组 -1为文件结尾, nil为未使用
  end

  def content(address) # 获取文件的内容
    result = ''
    while address != -1
      result << @blocks[address]
      address = @indices[address]
    end
    result
  end

  def avail_index # 可用的物理块索引
    i = nil # 可用的索引
    @indices.each_with_index do |value, index|
      if value == nil
        i = index
        @indices[i] = -1 # 保留这个位置
        break
      end
    end
    i # 未考虑索引未找到的情况
  end

  def store(address, strs) # 存储字符串数组,假设空间一定够用
    strs.each_with_index do |str, index|
      @blocks[address] = str # 存储字符串
      if index != (strs.length - 1) # 不是最后一个
        address = @indices[address] = avail_index # 当前索引指向下一个可存储的位置,addr指向下一个位置
      end
    end
  end

  def recycle(address) # 回收空间
    while address != -1
      @blocks[address] = ''
      old_address = address
      address = @indices[address]
      @indices[old_address] = nil
    end
  end

  def debug
    print @indices, "\n"
  end
end

class FCB # 文件控制块
  @@fat = FAT.new
  attr_reader :name

  def initialize(name)
    @name = name # 文件名
    @address = nil # 物理地址
    @length = 0 # 文件长度
  end

  def show # 显示文件内容
    @address == nil ? '' : @@fat.content(@address)
  end

  def write(content) # 创建文件内容
    @address = @@fat.avail_index # 假设一定可以获取成功
    @length = content.length # 保存文件的长度
    # 切分content
    strs = []
    remain_length = content.length
    start_index = 0
    while remain_length > 0
      if remain_length > 8
        strs << content[start_index, 8]
        remain_length -= 8
        start_index += 8
      else
        strs << content[start_index, remain_length]
        break
      end
    end
    @@fat.store @address, strs # 存储内容
  end

  def destroy # 回收删除文件所占用的块
    @@fat.recycle @address if @address != nil
  end

  def FCB.fat
    @@fat
  end
end

class Menu # 文件目录
  attr_reader :name, :parent
  attr_accessor :children, :fcbs

  def initialize(name, parent)
    @name = name # 目录名
    @parent = parent # 父目录
    @children = [] # 子目录
    @fcbs = [] # 拥有的文件
  end
end

class Manager # 文件管理器
  def initialize
    @root = Menu.new 'root', nil
    @cur_menu = @root
    @show_path = 'root'
  end

  def run
    loop do
      print "#{@show_path}> "
      temp = gets.chop!.split
      if temp.length == 1
        self.send temp[0].to_sym
      else
        self.send temp[0].to_sym, temp[1]
      end
      FCB.fat.debug
    end
  end

  private
  def format # 格式化
    @cur_menu = @root
    @root.fcbs.length.times { @root.fcbs.shift.destroy }
    @root.children.each { |menu| delete_menu @root, menu }
    @show_path = 'root'
  end

  def mkdir(arg) # 创建子目录
    menu_name = arg # 未考虑文件夹重名的情况
    @cur_menu.children << Menu.new(menu_name, @cur_menu)
  end

  def rmdir(arg) # 删除子目录,未考虑文件夹不存在的情况'
    menu = @cur_menu.children.detect { |menu| menu.name == arg }
    delete_menu @cur_menu, menu
  end

  def delete_menu(parent, menu) # 删除目录,递归使用
    menu.fcbs.length.times do # 删除文件夹下所有的文件
      fcb = menu.fcbs.shift
      puts "delete file : #{fcb.name}"
      fcb.destroy
    end
    menu.children.length.times do # 删除文件夹下所有的目录
      m = menu.children.first
      puts "delete dir : #{m.name}"
      delete_menu menu, m
    end
    parent.children.delete menu
  end

  def ls # 显示目录
    puts "dir : #{@cur_menu.children.map { |menu| menu.name + ' ' }.join}" if @cur_menu.children.length != 0
    puts "file : #{@cur_menu.fcbs.map { |fcb| fcb.name + ' ' }.join}" if @cur_menu.fcbs.length != 0
  end

  def cd(arg) # 更改当前目录
    menu_name = arg # 未考虑文件夹不存在的情况
    if menu_name == '..'
      if @cur_menu != @root
        @cur_menu = @cur_menu.parent
        @show_path = @show_path[0...(@show_path.rindex '\\')]
      end
    else
      @cur_menu = @cur_menu.children.detect { |menu| menu.name == menu_name }
      @show_path += '\\' + @cur_menu.name
    end
  end

  def create(arg) # 创建文件
    fcb_name = arg # 未考虑文件重名的情况
    @cur_menu.fcbs << FCB.new(fcb_name)
  end

  def read(arg) # 读文件
    fcb_name = arg # 未考虑文件不存在的情况
    fcb = @cur_menu.fcbs.detect { |fcb| fcb.name == fcb_name } # 查找文件
    puts fcb.show
  end

  def write(arg) # 写文件
    fcb_name = arg # 未考虑文件不存在的情况
    fcb = @cur_menu.fcbs.detect { |fcb| fcb.name == fcb_name } # 查找文件
    content = gets.chop!
    fcb.write content
  end

  def rm(arg) # 删除文件,未考虑文件不存在的情况
    fcb = @cur_menu.fcbs.detect { |fcb| fcb.name == arg } # 查找文件
    fcb.destroy
    @cur_menu.delete fcb
  end
end

manager = Manager.new
manager.run