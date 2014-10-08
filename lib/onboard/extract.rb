# encoding: utf-8

require 'fileutils'
require 'rubygems/package'
require 'thor'
require 'zlib'

module Onboard
  TAR_LONGLINK = '././@LongLink'

  class Extract
    attr_reader :archive, :link, :path

    def initialize(archive, link, path)
      @archive = archive
      @link = link
      @path = path
    end

    def longlink(entry)
      return File.join path, entry.read.strip if entry.full_name == TAR_LONGLINK
    end

    def xdir(dst, entry)
      return false unless entry.directory?
      FileUtils.rm_rf dst unless File.directory? dst
      FileUtils.mkdir_p dst, :mode => entry.header.mode, :verbose => false
    end

    def xfile(dst, entry)
      return false unless entry.file?
      FileUtils.rm_rf dst unless File.file? dst
      File.open dst, 'wb' do |f|
        f.print entry.read
      end
      FileUtils.chmod entry.header.mode, dst, :verbose => false
    end

    def xlink(dst, entry)
      return false unless entry.header.typeflag == '2' # Symlink!
      File.symlink entry.header.linkname, dst
    end

    def x(dst = nil)
      Gem::Package::TarReader.new(Zlib::GzipReader.open archive) do |tar|
        tar.each do |entry|
          dst = longlink(entry)
          dst ||= File.join path, entry.full_name
          xdir(dst, entry)
          xfile(dst, entry)
          xlink(dst, entry)
          dst = nil
        end
      end
    end
  end
end
