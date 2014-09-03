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
        if File.directory?(e)
          if needle.has_key?(File.basename(e))
            Dir.entries(e).select do |f|
              file = "#{e}/#{f}"
              if File.file?(file)
                if self.info_ext?(file)
                  if self.version(file).empty? == false
                    found[e] = self.version(file)
                  end
                end
              end
            end
          end
        end
      end
      return found
    end

    def info_ext?(file)
      File.extname(file) == '.info'
    end

    def version(file)
      File.open(file) do |g|
        g.each_line do |line|
          if line =~ /version/
            return line.scan(/.*?"(.*?)".*$/)[0].nil? ? '' : line.scan(/.*?"(.*?)".*$/)[0]
          end
        end
      end
    end
  end
end
