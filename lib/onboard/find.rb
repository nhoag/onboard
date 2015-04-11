#!/usr/bin/env ruby

require 'find'

module Onboard
  class Finder
    attr_reader :haystack, :needles

    def initialize(needles, haystack)
      @haystack = haystack
      @needles = needles
    end

    def source_link?(arg)
      !/@.*$/.match(arg).nil?
    end

    def array_match?(arg)
      needles.grep(/^#{File.basename(arg)}:/)
    end

    def locate
      found = {}
      Find.find(haystack) do |e|
        next unless File.directory?(e)
        next unless array_match?(e).any?
        file = info_file(e) unless source_link?(array_match?(e))
        found[e] = source_link?(array_match?(e)) ? '' : version(file)
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
