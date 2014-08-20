#!/usr/bin/env ruby

require 'find'

module Onboard
  class Finder
    attr_reader :needle, :haystack

    def initialize(needle, haystack)
      @needle = needle
      @haystack = haystack
    end

    def locate
      found = []
      Find.find(haystack) do |e|
        if File.directory?(e)
          if needle.include?(File.basename(e))
            Find.find(e) do |f|
              if File.extname(f) == '.info'
                found.push e
              end
            end
          end
        end
      end

      return found.uniq
    end
  end
end
