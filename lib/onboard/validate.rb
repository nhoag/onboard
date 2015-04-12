#!/usr/bin/env ruby

require 'rubygems/package'
require 'thor'

require_relative 'confirm'
require_relative 'download'
require_relative 'extract'
require_relative 'project'
require_relative 'release'
require_relative 'repo'

module Onboard
  class Validate < Thor
    attr_reader :core, :project, :version

    no_tasks do
      def initialize(project, version = '', core = '', answer)
        @answer = answer
        @core = core
        @project = project
        @version = version
      end

      def hacked?(path, repo)
        link = Download.new.build_link(project, version)
        Download.new.fetch(link)
        extract(link, path)
        changes = Repo.new(repo).st(true)
        return !Confirm.new('Proceed?').q(answer) unless changes
      end

      def extract(link, path)
        Extract.new(Download.new.path(link), link, path).x if verify(link, version)
      end

      def latest?(latest)
        if Gem::Dependency.new('', "~> #{latest}").match?('', "#{version}")
          say("#{project} is already at the latest version (#{latest}).", :yellow)
          return true
        else
          return false
        end
      end

      def verify(file, v = '')
        _version, md5 = Release.new(project, core).choose(v)
        if md5 == Digest::MD5.file(Download.new.path(file)).hexdigest
          return true
        else
          say("Verification failed for #{project} download!", :red)
        end
      end
    end
  end
end
