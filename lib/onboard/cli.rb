# encoding: utf-8
require 'thor'

module Onboard
  class CLI < Thor
    # TODO: switch from DOCROOT to CODEBASE - will enable more comprehensive searching
    desc "modules DOCROOT", "add default modules to DOCROOT"
    long_desc <<-LONGDESC
      `onboard modules` performs multiple tasks when installing contrib
      modules:

      * Checks for each module in the docroot

      * Downloads the latest version of each module

      * Adds and commits each module

      Default contrib modules: acquia_connector, fast_404, memcache
    LONGDESC
    option :addendum, :aliases => "-a", :type => :array, :desc => "Add projects to the default list"
    # TODO: Analyze codebase for core version?
    # ala - find ./CODEBASE -type f -name '*.info' | xargs -I {} grep -rn '^version = \"' {}
    option :core, :required => true, :aliases => "-c", :type => :numeric, :desc => "Specify Drupal core version"
    option :destination, :aliases => "-d", :desc => "Specify contrib destination relative to docroot"
    option :force, :aliases => "-f", :desc => "Force add modules (even if already present)"
    option :no, :aliases => "-n", :desc => "Assume 'no' for all prompts"
    option :projects, :aliases => "-p", :type => :array, :desc => "Pass a custom list of projects"
    # option :remove, :aliases => "-r", :desc => "Remove all copies of existing modules"
    option :subdir, :aliases => "-s", :desc => "Specify contrib subdir relative to 'modules'"
    option :vc, :type => :boolean, :default => true, :desc => "Enable/Disable version control handling"
    option :yes, :aliases => "-y", :desc => "Assume 'yes' for all prompts"
    def modules(docroot)
      require 'open-uri/cached'
      core = "#{options[:core]}.x"
      modules = []
      if options[:projects].nil? == false
        options[:projects].each { |x| modules.push x }
      else
        modules = ["acquia_connector", "fast_404", "memcache"]
      end
      if options[:addendum].nil? == false
        options[:addendum].each { |x| modules.push x }
      end
      subdir = options[:subdir].nil? == true ? "" : "/#{options[:subdir]}"
      destination = options[:destination].nil? ? "sites/all/modules#{subdir}" : "#{options[:destination]}#{subdir}"
      # TODO: new class - FindProject
      require 'find'
      found = []
      Find.find(docroot) { |e|
        if File.directory?(e)
          if modules.include?(File.basename(e))
            found.push e
          end
        end
      }
      names = []
      if found.nil? == false
        say("Projects exist at the following locations:", :yellow)
        found.each { |project|
          puts "  " + project
          names.push File.basename(project)
        }
        puts ""
      end
      diff = modules - names
      if options[:force] == 'force'
        diff = modules
      end
      if diff.empty? == false
        require 'nokogiri'
        say("Ready to add the following projects:", :green)
        diff.each { |x|
          puts "  " + "#{docroot}/#{destination}/#{x}"
        }
        puts ""
        if options[:no].nil? && options[:yes].nil?
          answer = ""
          while answer !~ /^[Y|N]$/i do
            answer = ask("Proceed? [Y|N]: ")
          end
          if answer =~ /^[N]$/i
            puts ""
            say("Script was exited.")
            exit
          end
        elsif options[:no] == 'no'
          say("Script was exited.")
          exit
        end
        # TODO: new class - RemoveProject
        require 'fileutils'
        diff.each { |x|
          FileUtils.rm_r "#{docroot}/#{destination}/#{x}" if File.directory?("#{docroot}/#{destination}/#{x}")
          project_uri = "http://updates.drupal.org/release-history/#{x}/#{core}"
          # TODO: replace 'open().read' with custom caching solution
          # TODO: new class - DownloadProject
          # TODO: best version when no stable found
          doc = Nokogiri::XML(open(project_uri).read)
          patch = {}
          major = doc.at_xpath('//recommended_major').content
          doc.xpath('//releases//release').each do |item|
            if !item.at_xpath('version_extra') && item.at_xpath('version_major').content == "#{major}"
              patch[item.at_xpath('version_patch').content.to_i] = item.at_xpath('mdhash').content
            end
          end
          minor = patch.keys.max
          archive = "http://ftp.drupal.org/files/projects/#{x}-#{core}-#{major}.#{minor}.tar.gz"
          # TODO: replace 'open().read' with custom caching solution
          open(archive).read
          uri = URI.parse(archive)
          targz = "/tmp/open-uri-503" + [ @path, uri.host, Digest::SHA1.hexdigest(archive) ].join('/')
          md5 = Digest::MD5.file(targz).hexdigest
          # TODO: retry with failed download verification
          if md5 == patch[minor]
            require_relative 'extract'
            Extract.new(targz, "#{docroot}/#{destination}").z
          else
            say("Verification failed for #{x} archive!", :red)
            exit
          end
        }
        if options[:vc] == true
          require_relative 'git'
          require_relative 'screen'
          diff.each { |x|
            width = Screen.new().width
            msg = "Pushing #{x} to the remote repo... "
            spaces = " " * (width - msg.length - 6)
            say(msg)
            say(spaces)
            Repo.new(docroot, "docroot/#{destination}/#{x}").update
            # TODO: right-justify '[done]'
            # TODO: error handling and conditional messaging for failures
            say("[done]", :green)
          }
        else
          diff.each { |x|
            say("#{x} added to codebase but changes are not yet tracked in version control.", :yellow)
          }
        end
      else
        say("All projects already in codebase.", :yellow)
      end
    end
  end
end
