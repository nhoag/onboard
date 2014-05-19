# encoding: utf-8
require 'fileutils'
require 'find'
require 'rubygems/package'
require 'zlib'

module Onboard

  TAR_LONGLINK = '././@LongLink'

  class Codebase
    attr_reader :path, :dest

    def initialize(path, dest = nil)
      @path = path
      @dest = dest
    end

    def rm
      FileUtils.rm_r path if File.directory?(path)
    end

    def extract
      Gem::Package::TarReader.new( Zlib::GzipReader.open path ) do |tar|
        dst = nil
        tar.each do |entry|
          if entry.full_name == TAR_LONGLINK
            dst = File.join dest, entry.read.strip
            next
          end
          dst ||= File.join dest, entry.full_name
          if entry.directory?
            FileUtils.rm_rf dst unless File.directory? dst
            FileUtils.mkdir_p dst, :mode => entry.header.mode, :verbose => false
          elsif entry.file?
            FileUtils.rm_rf dst unless File.file? dst
            File.open dst, "wb" do |f|
              f.print entry.read
            end
            FileUtils.chmod entry.header.mode, dst, :verbose => false
          elsif entry.header.typeflag == '2' #Symlink!
            File.symlink entry.header.linkname, dst
          end
          dst = nil
        end
      end
    end
  end
end
