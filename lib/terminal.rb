require_relative "./flags"

class Terminal
  TIOCGWINSZ = 0x40087468

  module CursorShape
    BLINKING_BLOCK     = 1
    STEADY_BLOCK       = 2
    BLINKING_UNDERLINE = 3
    STEADY_UNDERLINE   = 4
    BLINKING_BAR       = 5
    STEADY_BAR         = 6
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

  def self.size
    buf = [0, 0, 0, 0].pack("SSSS")
    rc = io.ioctl(TIOCGWINSZ, buf)
    raise "ioctl failed" if rc < 0
    rows, cols, xpx, ypx = buf.unpack("SSSS")
    { rows: rows, cols: cols, x_pixels: xpx, y_pixels: ypx }
  end

  def initialize(io = $stdout)
    @io = io
    @x, @y = 0, 0
    @text_mode = Flags.new(%i[])
  end

  # Move cursor to line, column
  def move(x, y)
    return if @x == x && @y == y
    @x, @y = x, y
    @io.print "\033[#{@y + 1};#{@x + 1}H"
    self
  end

  # Delete the rest of the line from cursor pos
  def trunc
    @io.print "\033[K"
    self
  end

  # Clear the screen
  def clear
    @io.print "\033[2J"
    self
  end

  def home
    @x, @y = 0, 0
    @io.print "\033[H"
    self
  end

  # Remove the scrollback buffer
  def clear_scroll
    @io.print "\033[3J"
    self
  end

  def alt_buffer
    @io.print "\033[?1049h"
    self
  end

  def restore_main_buffer
    @io.print "\033[?1049l"
    self
  end

  # Clears the terminal, allows drawing, etc. then returns to previous state
  def in_alt_buffer
    alt_buffer
    yield
  ensure
    restore_main_buffer
  end

  def cursor_shape=(shape_value)
    @io.print "\033[#{shape_value}q"
  end

  def show_cursor
    @io.print "\033[?25h"
    self
  end

  def hide_cursor
    @io.print "\033[?25l"
    self
  end

  def hidden_cursor
    hide_cursor
    yield
  ensure
    show_cursor
  end

  def text_mode
    @text_mode
  end

  def text_mode=(mode)
    return if mode == @text_mode

    @io.print "\033[0m"
    @io.print "\033[1m" if mode.set?(:bold)
    @io.print "\033[2m" if mode.set?(:dim)
    @io.print "\033[3m" if mode.set?(:italic)
    @io.print "\033[4m" if mode.set?(:underline)
    @io.print "\033[5m" if mode.set?(:blink)
    @io.print "\033[7m" if mode.set?(:reverse)
    @io.print "\033[8m" if mode.set?(:hidden)
    @io.print "\033[9m" if mode.set?(:strikethrough)
    @text_mode = mode
  end

  def in(fore, back)
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
      @io.print "\033[39m"
    else
      @io.print "\033[38;2;", color[0].to_s, ";", color[1].to_s, ";", color[2].to_s, "m"
    end
    @fore = color
  end

  def back=(color)
    return if @back == color

    if color.nil?
      @io.print "\033[49m"
    else
      @io.print "\033[48;2;", color[0].to_s, ";", color[1].to_s, ";", color[2].to_s, "m"
    end
    @back = color
  end

  def print(*args)
    width = 0
    args.each do |a|
      width += a.size
    end
    @io.print(*args)
    @x += width
  end
end
