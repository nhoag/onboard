# encoding: utf-8

require 'net/http'

module Onboard
  class Download
    def initialize(cache_dir='/tmp')
      @cache_dir = cache_dir
    end

    def path(url)
      File.join("", @cache_dir, Digest::MD5.hexdigest(url))
    end

    def fetch(url, max_age=1800)
      file_path = self.path(url)
      if File.exists? file_path
        return File.new(file_path).read if Time.now-File.mtime(file_path)<max_age
      end
      File.open(file_path, "w") do |data|
        data << Net::HTTP.get_response(URI.parse(url)).body
      end
    end
  end
end
