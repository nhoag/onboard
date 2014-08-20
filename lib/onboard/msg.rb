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
        width = Screen.new().width
        spaces = " " * (width - msg.length - 8)
        return msg + spaces
      end
    end
  end
end

