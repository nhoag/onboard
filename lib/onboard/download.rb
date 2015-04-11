# encoding: utf-8

require 'digest'
require 'fileutils'
require 'net/http'
require 'rubygems/package'

module Onboard
  DRUPAL_DL_LINK = 'http://ftp.drupal.org/files/projects/'

  class Download
    attr_reader :cache_dir

    def initialize(cache_dir = '/tmp/onboard/cache')
      @cache_dir = cache_dir
    end

    def build_link(project, version)
      DRUPAL_DL_LINK + "#{project}-#{version}.tar.gz"
    end

    def path(url)
      File.join('', @cache_dir, Digest::MD5.hexdigest(url))
    end

    def expired?(file_path, max_age)
      Time.now - File.mtime(file_path) < max_age
    end

    def fetch(url, max_age = 1800)
      FileUtils.mkdir_p(cache_dir) unless File.directory?(cache_dir)
      file_path = path(url)
      if File.exist? file_path
        return File.new(file_path).read unless expired?(file_path, max_age)
      end
      File.open(file_path, 'w') do |data|
        data << Net::HTTP.get_response(URI.parse(url)).body
      end
    end
  end
end
