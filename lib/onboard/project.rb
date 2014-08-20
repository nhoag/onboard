# encoding: utf-8
require 'fileutils'
require 'find'
require 'nokogiri'
require 'rubygems/package'
require 'zlib'

module Onboard

  TAR_LONGLINK = '././@LongLink'

  class Project
    attr_reader :feed, :path, :dest

    def initialize(args = {})
      @feed = "http://updates.drupal.org/release-history/#{args['project']}/#{args['core']}"
      @path = args['path']
      @dest = args['dest']
    end

    def dl
      doc = Nokogiri::XML(open(@feed).read)
      releases = {}
      doc.xpath('//releases//release').each do |item|
        if !item.at_xpath('version_extra')
          releases[item.at_xpath('mdhash').content] = item.at_xpath('download_link').content
        end
      end
      if releases.nil?
        doc.xpath('//releases//release').each do |item|
          releases[item.at_xpath('mdhash').content] = item.at_xpath('download_link').content
        end
      end
      return releases.first
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

