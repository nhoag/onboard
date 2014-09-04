# encoding: utf-8

require 'open-uri/cached'
require 'thor'

require_relative 'confirm'
require_relative 'find'
require_relative 'project'
require_relative 'repo'

module Onboard
  class CLI < Thor
    desc "projects CODEBASE", "add projects to CODEBASE"
    long_desc <<-LONGDESC
      `onboard projects` performs multiple tasks when installing contrib
      projects:

      * Checks for each project in the CODEBASE

      * Downloads the latest version of each project

      * Adds and commits each project

    LONGDESC
    option :branch, :aliases => "-b", :desc => "Specify repository branch to update"
    option :core, :required => true, :aliases => "-c", :type => :numeric, :desc => "Specify Drupal core version"
    option :path, :required => true, :aliases => "-p", :desc => "Specify project path relative to CODEBASE"
    option :force, :aliases => "-f", :desc => "Force add modules (even if already present)"
    option :no, :aliases => "-n", :desc => "Assume 'no' for all prompts"
    option :modules, :aliases => "-m", :type => :array, :desc => "Pass a list of modules"
    # option :delete, :aliases => "-d", :desc => "Delete existing projects"
    # option :source, :aliases => "-s", :desc => "Specify a project source other than drupal.org"
    option :themes, :aliases => "-t", :type => :array, :desc => "Pass a list of themes"
    option :vc, :type => :boolean, :default => true, :desc => "Enable/Disable version control handling"
    option :yes, :aliases => "-y", :desc => "Assume 'yes' for all prompts"
    def projects(codebase)
      core = "#{options[:core]}.x"
      projects = {}
      if options[:modules].nil? == false
        options[:modules].each { |x| projects[x] = '' }
      elsif options[:themes].nil? == false
        options[:themes].each { |x| projects[x] = '' }
      end
      path = "#{options[:path]}"
      found = Finder.new(projects, codebase).locate
      if found.empty? == false
        say("Projects exist at the following locations:", :yellow)
        found.each do |x, y|
          puts "  " + x
          projects[File.basename(x)] = y[0]
        end
        puts ""
      end
      if options[:force] != 'force'
        if found.empty? == false
          found.each do |x, y|
            projects.delete(File.basename(x))
          end
        end
      end
      if projects.empty? == false
        say("Ready to add the following projects:", :green)
        projects.each do |x, y|
          puts "  " + "#{codebase}/#{path}/#{x}"
        end
        puts ""
        if options[:no].nil? && options[:yes].nil?
          Confirm.new("Proceed?").yes?
        elsif options[:no] == 'no'
          say("Script was exited.")
          exit
        end
        prj = {}
        branch = options[:branch].nil? ? '' : options[:branch]
        prj['branch'] = branch
        prj['codebase'] = codebase
        prj['core'] = core
        prj['path'] = path
        prj['projects'] = projects
        prj['vc'] = options[:vc]
        Project.new(prj).dl
      else
        say("All projects already in codebase.", :yellow)
      end
    end
  end
end
