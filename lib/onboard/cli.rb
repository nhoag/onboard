# encoding: utf-8

require 'open-uri/cached'
require 'thor'

require_relative 'confirm'
require_relative 'find'
require_relative 'project'
require_relative 'repo'

module Onboard
  class CLI < Thor
    # TODO: switch from DOCROOT to CODEBASE to enable more comprehensive searching
    desc "projects CODEBASE", "add projects to CODEBASE"
    long_desc <<-LONGDESC
      `onboard projects` performs multiple tasks when installing contrib
      projects:

      * Checks for each project in the CODEBASE

      * Downloads the latest version of each project

      * Adds and commits each project

    LONGDESC
    # TODO: Analyze codebase for project version
    # ala - find ./CODEBASE -type f -name '*.info' | xargs -I {} grep -rn '^version = \"' {}
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
      projects = []
      if options[:modules].nil? == false
        options[:modules].each { |x| projects.push x }
      elsif options[:themes].nil? == false
        options[:themes].each { |x| projects.push x }
      end
      path = "#{options[:path]}"
      found = Finder.new(projects, codebase).locate
      if found.any?
        say("Projects exist at the following locations:", :yellow)
        found.each { |x| puts "  " + x }
        puts ""
      end
      if options[:force] != 'force'
        found.each do |x|
          projects.delete(File.basename(x))
        end
      end
      if projects.empty? == false
        say("Ready to add the following projects:", :green)
        projects.each do |x|
          puts "  " + "#{codebase}/#{path}/#{x}"
        end
        puts ""
        if options[:no].nil? && options[:yes].nil?
          Confirm.new("Proceed?").yes?
        elsif options[:no] == 'no'
          say("Script was exited.")
          exit
        end
        projects.each do |x|
          prm = {}
          prm['path'] = "#{codebase}/#{path}/#{x}"
          Project.new(prm).rm
          # TODO: replace 'open().read' with custom caching solution
          pdl = {}
          pdl['project'] = x
          pdl['core'] = core
          dl = Project.new(pdl).dl
          feed_md5, archive = dl
          # TODO: replace 'open().read' with custom caching solution
          open(archive).read
          uri = URI.parse(archive)
          targz = "/tmp/open-uri-503" + [ @path, uri.host, Digest::SHA1.hexdigest(archive) ].join('/')
          md5 = Digest::MD5.file(targz).hexdigest
          # TODO: retry download after failed download verification
          if md5 == feed_md5
            pex = {}
            pex['dest'] = "#{codebase}/#{path}"
            pex['path'] = targz 
            Project.new(pex).extract
          else
            say("Verification failed for #{x} archive!", :red)
            exit
          end
        end
        if options[:vc] == true
          require_relative 'msg'
          branch = options[:branch].nil? ? '' : options[:branch]
          repo = {}
          repo['branch'] = branch
          repo['codebase'] = codebase
          repo_info = Repo.new(repo).info
          projects.each do |x|
            acmsg = "Committing #{x} on #{repo_info['current_branch']} branch..."
            say(Msg.new(acmsg).format)
            repo['path'] = "#{path}/#{x}" 
            Repo.new(repo).update
            say("  [done]", :green)
            # TODO: error handling and conditional messaging for failures
          end
          pmsg = "Pushing all changes to #{repo_info['remotes']}..."
          say(Msg.new(pmsg).format)
          Repo.new(repo).push
          say("  [done]", :green)
        else
          projects.each do |x|
            say("#{x} added to codebase but changes are not yet tracked in version control.", :yellow)
          end
        end
      else
        say("All projects already in codebase.", :yellow)
      end
    end
  end
end
