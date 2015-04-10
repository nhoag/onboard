# encoding: utf-8

require 'thor'

require_relative 'confirm'
require_relative 'core'
require_relative 'find'
require_relative 'prepare'
require_relative 'project'

module Onboard
  class CLI < Thor
    desc 'update CODEBASE', 'update projects in CODEBASE'
    long_desc <<-LONGDESC
      `onboard update` performs multiple tasks when updating contrib projects:

      * Checks for each project in the CODEBASE

      * Downloads the latest release for each project

      * Adds and commits updates

    LONGDESC
    option :all, :default => false, :aliases => '-a', :desc => 'Perform all updates (default is security updates only)'
    option :core, :aliases => '-C', :desc => 'Update Drupal core only'
    option :contrib, :aliases => '-c', :desc => 'Update Drupal contrib only'
    option :distro, :aliases => '-d', :desc => 'Specify a distribution other than Drupal or Pressflow'
    option :no, :aliases => '-n', :desc => 'Assume "no" for all prompts'
    option :projects, :aliases => '-p', :desc => 'Specify projects to update'
    option :vc, :type => :boolean, :default => true, :desc => 'Enable/Disable version control handling'
    option :yes, :aliases => '-y', :desc => 'Assume "yes" for all prompts'
    def update(codebase)
      puts codebase
    end

    desc 'extend CODEBASE', 'add projects to CODEBASE'
    long_desc <<-LONGDESC
      `onboard extend` performs multiple tasks when installing contrib
      projects:

      * Checks for each project in the CODEBASE

      * Reports patched projects

      * Downloads the latest/stablest version of each project

      * Adds and commits each project

    LONGDESC
    option :delete, :aliases => '-D', :desc => 'Delete existing projects'
    option :destination, :required => true, :aliases => '-d', :desc => 'Specify project destination relative to CODEBASE'
    option :force, :aliases => '-f', :desc => 'Force add projects (even if already present)'
    option :no, :aliases => '-n', :desc => 'Assume "no" for all prompts'
    option :projects, :aliases => '-p', :type => :array, :desc => 'List of projects (project[:version][@link])'
    option :vc, :type => :boolean, :default => true, :desc => 'Enable/Disable version control handling'
    option :yes, :aliases => '-y', :desc => 'Assume "yes" for all prompts'
    def extend(codebase)
      Project.new(Prepare.new(codebase, options)).dl
    end

    desc 'lift CODEBASE', 'add lift to CODEBASE'
    long_desc <<-LONGDESC
      `onboard lift` performs multiple tasks when adding lift:

      * Checks for each lift component in the CODEBASE

      * Downloads the recommended release for each lift component

      * Adds and commits updates

    LONGDESC
    option :no, :aliases => '-n', :desc => 'Assume "no" for all prompts'
    option :vc, :type => :boolean, :default => true, :desc => 'Enable/Disable version control handling'
    option :yes, :aliases => '-y', :desc => 'Assume "yes" for all prompts'
    def lift(codebase)
      puts codebase
    end
  end
end
