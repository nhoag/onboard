#!/usr/bin/env ruby

require 'thor'

require_relative 'screen'

module Onboard
  class Msg < Thor
    attr_reader :msg

    no_tasks do
      def initialize(msg = '')
        @msg = msg
      end

      def format
        height, width = Screen.new().size
        spaces = " " * (width - msg.length - 8)
        say(msg + spaces)
      end
    end
  end
end

