# encoding: utf-8

require 'thor'

require_relative 'confirm'
require_relative 'core'
require_relative 'find'
require_relative 'extend'

module Onboard
  class Prepare < Thor
    attr_reader :codebase, :found, :info, :options, :projects

    no_tasks do
      def initialize(codebase, options)
        @options = options
        @codebase = codebase
        @found = Finder.new(options[:projects], codebase).locate
        @info = [codebase, Core.new(codebase).info['major'], answer]
        @projects = projects_build(options[:projects])
      end

      def at_split(arg)
        arg.split('@')
      end

      def colon_split(arg)
        arg.split(':')
      end

      def assign(arg)
        arg.nil? ? '' : arg
      end

      def project_hash(version, link)
        project = {}
        project['version'] = assign(version)
        project['link'] = assign(link)
        project
      end

      def projects_build(arg)
        data = {}
        arg.each do |x|
          at = at_split(x)
          colon = colon_split(at[0])
          project = assign(colon[0])
          data[project] = project_hash(colon[1], at[1])
        end
        data
      end

      def report
        say('Projects exist at the following locations:', :yellow)
        found.each do |x, y|
          puts '  ' + x
          projects[File.basename(x)] = y
        end
        puts ''
        projects
      end

      def answer
        if options['no'] == 'no'
          return 'n'
        elsif options['yes'] == 'yes'
          return 'y'
        else
          ''
        end
      end

      def delete(proj)
        # TODO: check for patches before delete
        return proj unless options[:delete] == 'delete'
        say('Ready to delete existing projects:', :yellow)
        Confirm.new('Proceed?', true).q(answer)
        found.each do |x, _|
          Extend.new.clean(x)
          proj[File.basename(x)] = ''
        end
        proj
      end

      def force(proj)
        return proj if options[:force] == 'force' || proj.empty?
        found.each do |x, _|
          proj.delete(File.basename(x))
        end
        proj
      end

      def add(proj)
        say('Ready to add the following projects:', :green)
        proj.each do |x, _|
          puts '  ' + "#{codebase}/#{options[:destination]}/#{x}"
        end
        puts ''
      end

      def confirm(proj)
        add(proj)
        ans = answer
        Confirm.new('Proceed?', true).q(ans)
      end

      def void
        say('All projects already in codebase.', :yellow)
        exit
      end

      def do
        proj = force(found.any? ? delete(report) : projects)
        return void if proj.empty?
        confirm(proj)
        [info, proj]
      end
    end
  end
end
