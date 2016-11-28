class Dispatcher

  def initialize
    @instructs = get_instructs # 指令序列
    @blocks = Array.new(4) # 程序拥有的内存块
    @lost_counter = 0 # 缺页数
  end

  def run
    @instructs.each_index do |i|
      instruct = @instructs[i]
      page = get_page instruct
      puts '============================================================'
      puts "current instruct i##{instruct} in p##{page}"
      # puts 'input enter to continue'
      # gets
      if exist? page
        puts "page exists in b##{@blocks.find_index get_page(instruct)}"
      else
        if @blocks.include? nil
          pos = nil_pos
          puts "page will insert in block##{pos}"
          @blocks[pos] = get_page instruct
        else
          pos = swap i
          puts "page isn't exist in blocks, block##{pos} will be swapped"
          puts "number of lost pages is #{@lost_counter += 1}"
        end
      end
      embed i
    end
    puts '============================================================'
    puts "program is end, and the percent of lost pages is #{@lost_counter*100/@instructs.length}%"
  end

  protected
  #子类实现
  def swap(it_index)
  end

  def embed(index)
  end

  # 320条随机指令顺序产生
  def get_instructs
    # puts '请输入第一条指令号(0~320):'
    # pc = gets.to_i - 1
    pc = 0
    flag = 0 # 辅助执行访问次序的生成
    puts '按照要求产生的320个随机数:'
    Array.new(320) do |i|
      pc = case flag
             when 1
               rand(320)
             when 3
               pc+rand(320-pc)
             else
               (pc+1)%320
           end
      flag = (flag+1) % 4
      printf '%03d ', pc
      puts if (i+1) % 10 == 0
      pc
    end
  end

  # 获取指令在页表中的位置

  def get_page(instruct)
    instruct/10
  end

  # 判断块中是否存在该页
  def exist?(page)
    @blocks.include? page
  end

  # 返回blocks中未使用的位置
  def nil_pos
    @blocks.each_index do |i|
      return i if @blocks[i] == nil
    end
  end
end