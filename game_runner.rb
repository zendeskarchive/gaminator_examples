# encoding: utf-8

require "curses"

class GameRunner
  include Curses

  def initialize(game_class)
    init_screen
    cbreak
    noecho
    stdscr.nodelay = 1
    curs_set(0)

    @width = cols
    @height = lines
    @win = Window.new(@height, @width, 0, 0)
    @win.box("|", "-")

    @game = game_class.new(@width - 2, @height - 2)
  end

  def run
    begin
      loop do
        tick_game
        handle_input

        render_objects

        @win.refresh
        clear_window

        sleep(@game.sleep_time)
      end
    ensure
      close_screen
    end
  end

  def handle_input
    char = getch
    action = @game.input_map[char]
    if action && @game.respond_to?(action)
      @game.send(action)
    end
  end

  def tick_game
    @game.tick
  end

  def render_objects
    @game.objects.each do |object|
      @win.setpos(object.y + 1, object.x + 1)
      @win.addstr(object.char)
    end
  end

  def clear_window
    1.upto(@height - 2) do |y|
      1.upto(@width - 2) do |x|
        @win.setpos(y, x)
        @win.addstr(" ")
      end
    end
  end
end
