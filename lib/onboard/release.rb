# encoding: utf-8

require 'nokogiri'

require_relative 'download'

module Onboard
  DRUPAL_PRJ_FEED = 'http://updates.drupal.org/release-history/'

  class Release
    attr_reader :core, :doc, :feed, :project

    def initialize(project, core)
      @core = core
      @project = project
      @doc = build_doc
    end

    def build_doc
      feed = "#{DRUPAL_PRJ_FEED}#{project}/#{core}"
      Download.new.fetch(feed)
      xml = File.open(Download.new.path(feed))
      Nokogiri::XML(xml)
    end

    def specify(version, releases)
      if releases['stable'][version].nil? == false
        return version, releases['stable'][version]
      elsif releases['extra'][version].nil? == false
        return version, releases['extra'][version]
      end
    end

    def choose(version = '')
      releases = releases_get
      if version.empty? == false
        return specify(version, releases)
      elsif releases['stable'].empty? == false
        return releases['stable'].first
      elsif releases['extra'].empty? == false
        return releases['extra'].first
      end
    end

    def releases_get
      releases = { 'stable' => {}, 'extra' => {} }
      doc.xpath('//releases//release').each do |item|
        md5 = item.at_xpath('mdhash').content
        version = item.at_xpath('version').content
        status = item.at_xpath('version_extra').nil? ? 'stable' : 'extra'
        releases[status][version] = md5
      end
      releases
    end
  end
end
