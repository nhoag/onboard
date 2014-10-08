#!/usr/bin/env ruby

require 'git'

module Onboard
  class Source
    attr_reader :source

    no_tasks do
      def initialize(source)
        @source = source
      end

      def get
      end
    end
  end
end
