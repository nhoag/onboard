#!/usr/bin/env ruby

require 'curses'

module Onboard
  class Screen
    Curses.init_screen()

    def width
      return Curses.cols
    end
  end
end
