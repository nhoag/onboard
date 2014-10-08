# encoding: utf-8

require 'thor'

require_relative 'confirm'
require_relative 'project'

module Onboard
  class Prepare < Thor
    attr_reader :codebase, :found, :options, :projects

    no_tasks do
      def initialize(codebase, found, options)
        @codebase = codebase
        @found = found
        @options = options
        @projects = Hash[options['projects'].map { |k, v| [k, v] }]
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
          Project.new.clean(x)
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
        if found.empty? == false
          proj = report
          proj = delete(proj)
        else
          proj = projects
        end
        proj = force(proj)
        confirm(proj) unless proj.empty?
        return proj, answer unless proj.empty?
        void
      end
    end
  end
end
