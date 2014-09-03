#!/usr/bin/env ruby

require 'io/console'

module Onboard
  class Screen

    def size
      IO.console.winsize
      rescue LoadError
      [Integer(`tput li`), Integer(`tput co`)]
    end
  end
end

