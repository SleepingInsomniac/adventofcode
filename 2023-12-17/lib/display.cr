module Display
  def self.text(x, y, string = "", truncate = false)
    move_to(x, y)
    trunc if truncate
    print string
  end

  def self.move_to(x, y)
    print "\033[#{y + 1};#{x + 1}H"
  end

  def self.clear
    print "\033[2J"
  end

  def self.home
    print "\033[H"
  end

  def self.cursor_off
    print "\033[?25l"
  end

  def self.cursor_on
    print "\033[?25h"
  end

  def self.trunc
    print "\033[K"
  end
end
