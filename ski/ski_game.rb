# encoding: utf-8

require "bundler/setup"
require "gaminator"

class SkiGame
  class Tree < Struct.new(:x, :y)
    def char
      "#"
    end

    def color
      Curses::COLOR_GREEN
    end
  end

  class Skier < Struct.new(:x, :y)
    def char
      "⇑"
    end
  end

  def initialize(width, height)
    @ticks = 0
    @width = width
    @height = height
    @skier = Skier.new(@width / 5, @height - 5)
    @trees = [Tree.new(30, 3)]
    @score = 0
    reset_speed
  end

  def reset_speed
    @speed = 0
  end

  def objects
    [@skier] + @trees
  end

  def input_map
    {
      ?a => :move_left,
      ?d => :move_right,
      ?w => :speed_up,
      ?s => :slow_down,
      ?q => :exit,
    }
  end

  def move_left
    @skier.x = @skier.x - 1
  end

  def move_right
    @skier.x = @skier.x + 1
  end

  def slow_down
    @speed -= 1
  end

  def speed_up
    @speed += 1
  end

  def tick
    check_collision
    move_trees
    cleanup_trees
    spawn_trees
    increase_score
    increase_tick_count
    reset_speed
  end

  def move_trees
    @trees.each do |tree|
      tree.y = tree.y + 1
    end
  end

  def check_collision
    if collision?
      exit
    end
  end

  def collision?
    @trees.any? do |tree|
      tree.y == @skier.y &&
        tree.x == @skier.x
    end
  end

  def spawn_trees
    count = (rand * 1.5 + @ticks * 0.005).to_i
    count.times do
      @trees << Tree.new(rand(@width), 0)
    end
  end

  def cleanup_trees
    @trees = @trees.select do |tree|
     on_plane?(tree.x, tree.y)
    end
  end

  def on_plane?(x, y)
    x.between?(1, @width - 2) &&
      y.between?(1, @height - 2)
  end

  def increase_score
    @score += 0.7 + @speed * 0.5
  end

  def increase_tick_count
    @ticks += 1
  end

  def sleep_time
    0.05 - @speed * 0.05
  end

  def textbox_content
    "Your distance: %dm" % @score
  end

  def exit
    Kernel.exit
  end

  def exit_message
    puts "You're dead ;(. You rode %d meters down the hill though!" % @score
  end
end


Gaminator::Runner.new(SkiGame).run
