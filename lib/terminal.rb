require "io/console"
require_relative "./flags"

class Terminal
  TIOCGWINSZ = 0x40087468 # Magic value for IOCTL
  ESC = "\033"
  CSI = "#{ESC}["

  module ANSI

    module CLEAR
      TO_END   = "0J"
      TO_START = "1J"
      ALL      = "2J" # Clear screen
      SCROLL   = "3J" # Clears the scrollback buffer too
    end

    module CURSOR
      TRUNC   = "K" # Truncate line
      HOME    = "H" # Return to top left
      UP      = "A"
      DOWN    = "B"
      FORWARD = "C"
      BACK    = "D"
      SAVE    = "s" # Save cursor position
      RESTORE = "u" # Restore cursor position
      HIDE    = "?25l"
      SHOW    = "?25h"

      module SHAPE
        module BLOCK
          BLINKING = 1
          STEADY   = 2
        end

        module UNDERLINE
          BLINKING = 3
          STEADY   = 4
        end

        module BAR
          BLINKING = 5
          STEADY   = 6
        end
      end
    end

    module ALT_BUFFER
      ENTER = "?1049h"
      LEAVE = "?1049l"
    end
  end

  TEXT_MODES = %i[
    bold
    dim
    italic
    underline
    blink
    reverse
    hidden
    strikethrough
  ]

  def self.size = IO.console.winsize

  attr_reader :x, :y, :cursor_shape, :text_mode, :fore, :back, :width, :height

  def initialize(io = $stdout)
    @io = io
    @x, @y = 0, 0
    @cursor_shape = ANSI::CURSOR::SHAPE::BLOCK::BLINKING
    @text_mode = Flags.new(TEXT_MODES)
    @height, @width = self.class.size
    trap("SIGWINCH") do
      @height, @width = self.class.size
    end
  end

  # Move cursor to line, column
  def move(x, y)
    return if @x == x && @y == y
    @x, @y = x, y
    put("#{@y + 1};#{@x + 1}H")
  end

  def trunc               = put(ANSI::CURSOR::TRUNK) # Delete the rest of the line from cursor pos
  def clear               = put(ANSI::CLEAR::ALL)    # Clear the screen
  def home                = put(ANSI::CURSOR::HOME)  # Return to top left)
  def clear_scroll        = put(ANSI::CLEAR::SCROLL) # Remove the scrollback buffer
  def alt_buffer          = put(ANSI::ALT_BUFFER::ENTER)
  def restore_main_buffer = put(ANSI::ALT_BUFFER::LEAVE)
  def show_cursor         = put(ANSI::CURSOR::SHOW)
  def hide_cursor         = put(ANSI::CURSOR::HIDE)

  # Clears the terminal, allows drawing, etc. then returns to previous state
  def in_alt_buffer
    alt_buffer
    yield
  ensure
    restore_main_buffer
  end

  def steady
    return if steady?
    @cursor_shape += 1
    self
  end

  def steady? = @cursor_shape.even?

  def blink
    return if blinking?
    @cursor_shape -= 1
    self
  end

  def blinking? = @cursor_shape.odd?
  def block     = put(blinking? ? ANSI::CURSOR::SHAPE::BLOCK::BLINKING : ANSI::CURSOR::SHAPE::BLOCK::STEADY)
  def underline = put(blinking? ? ANSI::CURSOR::SHAPE::UNDERLINE::BLINKING : ANSI::CURSOR::SHAPE::UNDERLINE::STEADY)
  def bar       = put(blinking? ? ANSI::CURSOR::SHAPE::BAR::BLINKING : ANSI::CURSOR::SHAPE::BAR::STEADY)

  def cursor_shape=(shape_value)
    @cursor_shape = shape_value
    put("#{shape_value}q")
  end

  def hidden_cursor
    hide_cursor
    yield
  ensure
    show_cursor
  end

  def text_mode=(mode)
    return if mode == @text_mode
    @text_mode = mode

    put "0m"
    TEXT_MODES.each.with_index do |m, i|
      put "#{i}m" if mode.set?(m)
    end

    self
  end

  def with_color(fore, back)
    old_fore = @fore
    old_back = @back
    self.fore = fore
    self.back = back
    yield
  ensure
    self.fore = old_fore
    self.back = old_back
  end

  def fore=(color)
    return if @fore == color

    if color.nil?
      put "39m"
    else
      put "38;2;#{color.join(";")}m"
    end

    @fore = color
  end

  def back=(color)
    return if @back == color

    if color.nil?
      put "49m"
    else
      put "48;2;#{color.join(";")}m"
    end
    @back = color
  end

  def print(*args)
    return if x < 0 || x >= width || y < 0 || y >= height

    width = 0
    args.each do |a|
      width += a.size
    end
    @io.print(*args)
    @x += width
  end

  private

  def put(sequence)
    @io.print "#{CSI}#{sequence}"
    self
  end
end
