#!/usr/bin/env ruby

require 'gaminator'

class PrettyLight
  attr_reader :x, :y, :texture
  def initialize(x, y, start_color)
    @x = x
    @y = y
    @color = start_color
    @texture = ['#', '$', '%', '^', '&']
  end

  def color
    @color
  end

  def tick
    @color = (@color + 1) % 256
  end
end

class PrettyLights
  attr_reader :sleep_time
  def initialize(width, height)
    @width = width
    @height = height
    @sleep_time = 0.1
    @lights = []
    100.times do |i|
      @lights << PrettyLight.new(i, 0, i + 8)
    end
  end

  def objects
    @lights
  end

  def textbox_content
    'Sit back and watch the pretty lights. Hit / when you\'re done.'
  end

  def texture

  end

  def tick
    @lights.each do |l|
      l.tick
    end
  end

  def wait?
    false
  end

  def input_map
    {
      ?/ => :stop_the_show,
    }
  end

  def exit_message
    'Yeah, go back to your sad, colorless world.'
  end

  def stop_the_show
    exit
  end

end

Gaminator::Runner.new(PrettyLights, :rows => 12, :cols => 102).run