# encoding: utf-8

require 'fileutils'
require 'thor'

require_relative 'download'
require_relative 'extract'
require_relative 'release'
require_relative 'repo_bridge'
require_relative 'validate'

module Onboard
  class Project < Thor
    attr_reader :answer, :codebase, :core, :options, :path, :projects, :size

    no_tasks do
      def initialize(info, projects, options)
        @answer = info[2]
        @codebase = info[0]
        @core = info[1]
        @options = options
        @path = "#{codebase}/#{options['destination']}"
        @projects = projects
        @size = projects.length
      end

      def continue?(project, i, latest)
        return true if i.nil? || i['version'].to_s.empty?
        clean("#{path}/#{project}")
        repo = build_vc(project)
        check = Validate.new(project, i['version'], core, answer)
        if check.latest?(latest) || check.hacked?(path, repo)
          return false
        else
          return true
        end
      end

      def reset(project)
        clean("#{path}/#{project}")
        repo = build_vc(project)
        RepoBridge.new(repo).co
      end

      def valid?(project, version, link)
        Validate.new(project, version, core, answer).verify(link)
      end

      def deploy(project, version)
        clean("#{path}/#{project}")
        link = Download.new.build_link(project, version)
        Download.new.fetch(link)
        # TODO: retry download after failed download verification
        Extract.new(Download.new.path(link), link, path).x if valid?(project, version, link)
      end

      def push(changes)
        return false unless changes
        repo = build_vc
        RepoBridge.new(repo).push
      end

      def update(project, changes, count)
        if options['vc']
          repo = build_vc(project)
          update = RepoBridge.new(repo).up
          changes = changes ? changes : update
          push(changes) if count == 0
          return changes
        else
          say("#{project} added to codebase but changes are not yet under version control.", :yellow)
        end
      end

      def delegate(project, i, changes, count)
        latest, _md5 = Release.new(project, core).choose
        if continue?(project, i, latest)
          deploy(project, latest)
          return update(project, changes, count)
        else
          reset(project)
        end
      end

      def dl
        changes = false
        count = size
        projects.each do |x, y|
          count -= 1
          changes = delegate(x, y, changes, count)
        end
      end

      def build_vc(x = '')
        repo = {}
        repo['codebase'] = codebase
        repo['path'] = @vc_path
        repo['project'] = x
        repo
      end

      def clean(arg)
        FileUtils.rm_r arg if File.directory?(arg)
      end
    end
  end
end
