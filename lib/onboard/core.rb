# encoding: utf-8

require 'find'

module Onboard
  class Core
    attr_reader :codebase

    def initialize(codebase)
      @codebase = codebase
    end

    def parser(file, v, pattern)
      open(file) do |f|
        f.each_line.find do |line|
          next unless v.match(line)
          return line.scan(pattern)[0][0] unless line.scan(pattern)[0].nil?
        end
      end
    end

    def drupal(file)
      pattern = /.*?"(.*?)".*$/
      v = /version/
      parser(file, v, pattern)
    end

    def pressflow(file)
      pattern = /^.*?,\s\'(.*?)\'.*$/
      v = /define\(\'VERSION/
      parser(file, v, pattern)
    end

    def collector
      i = {}
      Find.find(codebase) do |e|
        next unless File.file?(e)
        i['drupal'] = drupal(e) if %r{modules/system/system\.info$} =~ e
        i['pressflow'] = pressflow(e) if %r{modules/system/system\.module$} =~ e
        if %r{includes/bootstrap\.inc$} =~ e
          i['distro'] = pressflow?(e) ? 'pressflow' : 'drupal'
        end
      end
      i
    end

    def info
      core = {}
      i = collector
      version = i['pressflow'].nil? ? i['drupal'] : i['pressflow']
      core['distro'] = i['distro']
      core['version'] = version
      core['major'] = "#{version.scan(/^(.*?)\..*$/)[0][0]}.x"
      core
    end

    def pressflow?(file)
      pattern = /drupal_page_cache_header_external/
      open(file) do |f|
        f.each_line.find do |line|
          next unless pattern.match(line)
          return true
        end
      end
    end
  end
end
