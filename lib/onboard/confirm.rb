#!/usr/bin/env ruby

require 'thor'

module Onboard
  class Confirm < Thor
    attr_reader :message

    no_tasks do
      def initialize(message)
        @message = message
      end

      def yes?
        answer = ""
        while answer !~ /^[Y|N]$/i do
          answer = ask(message + " [Y|N]: ")
          puts ""
        end
        if answer =~ /^[N]$/i
          say("Script was exited.")
          exit
        end
      end
    end
  end
end
