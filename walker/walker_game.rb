# encoding: utf-8

require "bundler/setup"
require "gaminator"

class WalkerGame
  class Player < Struct.new(:x, :y)
    def char
      "@"
    end

    def color
      Curses::COLOR_RED
    end

    def move(x, y)
      self.x+=x
      self.y+=y
    end
  end

  class Item < Struct.new(:x, :y)
    def blocking?
      false
    end

    def winning?
      false
    end
  end

  class Wall < Item
    def char
      '#'
    end

    def blocking?
      true
    end
  end

  class Finish < Item
    def char
      'F'
    end

    def winning?
      true
    end

    def color
      Curses::COLOR_BLUE
    end
  end

  class Start < Item
    def char
      ''
    end
  end

  class Map < Hash
    attr_accessor :types

    OBJECT_MAPPING = {
      '#' => Wall,
      "S" => Start,
      "F" => Finish
    }

    def get(x, y)
      self[x][y] if self[x]
    end

    def set(x, y, value)
      self[x] = {} unless self[x]
      self[x][y] = value
    end

    def load_map(file)
      @objects = []
      @types = {}
      file = File.open(file)
      y = 0
      file.each_line do |line|
        x = 0
        line.chomp.each_char do |char|
          self.resolve_object(char, x, y)
          x += 1
        end
        y += 1
      end
    end

    def resolve_object(char, x, y)
      if klass = OBJECT_MAPPING[char]
        instance = klass.new(x, y)
        self.set(x, y, instance)
        @objects.push instance
        name = klass.name.split('::').last
        @types[name] ||= []
        @types[name].push(instance)
      end
    end

    def objects
      @objects
    end
  end

  def initialize(width, height)
    @ticks = 100
    @width = width
    @height = height
    @score = 0
    @map = Map.new
    @map.load_map File.join(File.dirname(__FILE__), "map.txt")
    puts @map.types.keys
    start = @map.types['Start'].first
    @player = Player.new(start.x,start.y)
    reset_speed
  end

  def wait?
    true
  end

  def reset_speed
    @speed = 0
  end

  def tick
    increase_tick_count
  end

  def increase_tick_count
    @ticks += 1
  end

  def input_map
    {
      "a" => :move_left,
      "w" => :move_top,
      "s" => :move_down,
      "d" => :move_right
    }
  end

  def move_right
    move 1, 0 if @player.y < @width - 1
  end

  def move_left
    move -1, 0 if @player.x > 0
  end

  def move_top
    move 0, -1 if @player.y > 0
  end

  def move_down
    move 0, 1 if @player.y < @height - 1
  end

  def move(x, y)
    new_x, new_y = @player.x + x, @player.y + y
    if something = @map.get(new_x, new_y)
      return if something.blocking?
      finish if something.winning?
    end
    @player.move x, y
  end

  def objects
    [@player] + @map.objects
  end

  def finish
    @status = "Win!"
    exit
  end

  def textbox_content
    ""
  end

  def exit
    Kernel.exit
  end

  def exit_message
    @status
  end


  def sleep_time
    0.05
  end

end

Gaminator::Runner.new(WalkerGame).run
