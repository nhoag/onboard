#!/usr/bin/env ruby

require 'thor'

module Onboard
  class Confirm < Thor
    attr_reader :message, :full_stop

    no_tasks do
      def initialize(message, full_stop = false)
        @message = message
        @full_stop = full_stop
      end

      def yes?
        answer = ""
        while answer !~ /^[Y|N]$/i do
          answer = ask(message + " [Y|N]: ")
          puts ""
        end
        if answer =~ /^[N]$/i
          if full_stop
            say("Script was exited.")
            exit
          else
            say("Action was aborted.")
            return false
          end
        elsif answer =~ /^[Y]$/i
          return true
        end
      end
    end
  end
end
