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
      found = {}
      Find.find(haystack) do |e|
        next unless File.directory?(e)
        next unless needle.include?(File.basename(e))
        file = info_file(e)
        found[e] = version(file)
      end
      found
    end

    def info_file(dir)
      Find.find(dir).select do |f|
        next unless File.file?(f)
        return f if info_ext?(f)
      end
    end

    def info_ext?(file)
      File.extname(file) == '.info'
    end

    def version(file)
      File.open(file) do |g|
        g.each_line do |line|
          if line =~ /version/
            return line.scan(/.*?"(.*?)".*$/)[0].nil? ? false : line.scan(/.*?"(.*?)".*$/)[0][0]
          end
        end
      end
    end
  end
end
