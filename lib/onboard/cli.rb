# encoding: utf-8
require 'thor'
require 'open-uri/cached'
require_relative 'codebase'

module Onboard
  class CLI < Thor
    # TODO: switch from DOCROOT to CODEBASE to enable more comprehensive searching
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
      require 'find'
      found = []
      Find.find(docroot) do |e|
        if File.directory?(e)
          if modules.include?(File.basename(e))
            found.push e
          end
        end
      end
      if found.any?
        say("Projects exist at the following locations:", :yellow)
        found.each do |project|
          puts "  " + project
        end
        puts ""
      end
      if options[:force] != 'force'
        found.each do |x|
          modules.delete(File.basename(x))
        end
      end
      if modules.empty? == false
        say("Ready to add the following projects:", :green)
        modules.each do |x|
          puts "  " + "#{docroot}/#{destination}/#{x}"
        end
        puts ""
        if options[:no].nil? && options[:yes].nil?
          answer = ""
          while answer !~ /^[Y|N]$/i do
            answer = ask("Proceed? [Y|N]: ")
            puts ""
          end
          if answer =~ /^[N]$/i
            say("Script was exited.")
            exit
          end
        elsif options[:no] == 'no'
          say("Script was exited.")
          exit
        end
        modules.each do |x|
          Codebase.new("#{docroot}/#{destination}/#{x}").rm
          # TODO: replace 'open().read' with custom caching solution
          require_relative 'contrib'
          dl = Contrib.new(x, core).dl
          feed_md5, archive = dl
          # TODO: replace 'open().read' with custom caching solution
          open(archive).read
          uri = URI.parse(archive)
          targz = "/tmp/open-uri-503" + [ @path, uri.host, Digest::SHA1.hexdigest(archive) ].join('/')
          md5 = Digest::MD5.file(targz).hexdigest
          # TODO: retry download after failed download verification
          if md5 == feed_md5
            Codebase.new(targz, "#{docroot}/#{destination}").extract
          else
            say("Verification failed for #{x} archive!", :red)
            exit
          end
        end
        if options[:vc] == true
          require_relative 'repo'
          require_relative 'screen'
          modules.each do |x|
            width = Screen.new().width
            msg = "Pushing #{x} to the remote repo..."
            spaces = " " * (width - msg.length - 8)
            say(msg + spaces)
            Repo.new(docroot, "docroot/#{destination}/#{x}").update
            # TODO: error handling and conditional messaging for failures
            say("  [done]", :green)
          end
        else
          modules.each do |x|
            say("#{x} added to codebase but changes are not yet tracked in version control.", :yellow)
          end
        end
      else
        say("All projects already in codebase.", :yellow)
      end
    end
  end
end
