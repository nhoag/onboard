#!/usr/bin/env ruby

require 'fileutils'
require 'git'
require 'pathname'
require 'thor'

module Onboard
  class Patch
    attr_reader :dir

    def initialize(dir = '/tmp/onboard/patches')
      @dir = dir
    end

    def patch_dir
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def cleanup
      Dir.foreach(dir) do |item|
        file = "#{dir}/#{item}"
        FileUtils.rm_r file if File.zero?(file)
      end
    end

    def open(project)
      patch_dir
      patch_file = File.open("#{dir}/#{Time.now.to_i}_#{project}.patch", 'w')
      patch_file
    end

    def close(patch_file = '')
      patch_file.close
      cleanup
    end
  end
end
