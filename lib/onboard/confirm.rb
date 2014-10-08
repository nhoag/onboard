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

      def q(prefill = '')
        return response(prefill) if prefill =~ /^[N]$/i || prefill =~ /^[Y]$/i
        answer = ''
        while answer !~ /^[Y|N]$/i
          answer = ask(message + ' [Y|N]: ')
          puts ''
        end
        response(answer)
      end

      def no
        if full_stop
          say('Script was exited.')
          exit
        else
          say('Action was aborted.')
          return false
        end
      end

      def response(answer)
        if answer =~ /^[N]$/i
          no
        elsif answer =~ /^[Y]$/i
          return true
        end
      end
    end
  end
end
