# encoding: utf-8
require 'nokogiri'

module Onboard
  class Contrib
    attr_reader :project, :core

    def initialize(project, core)
      @feed = "http://updates.drupal.org/release-history/#{project}/#{core}"
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
  end
end
