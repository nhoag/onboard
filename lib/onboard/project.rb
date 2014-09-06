# encoding: utf-8

require 'fileutils'
require 'find'
require 'nokogiri'
require 'rubygems/package'
require 'thor'
require 'zlib'

require_relative 'confirm'
require_relative 'download'
require_relative 'msg'
require_relative 'repo'

module Onboard

  TAR_LONGLINK = '././@LongLink'
  DRUPAL_PRJ_FEED = "http://updates.drupal.org/release-history/"
  DRUPAL_DL_LINK = "http://ftp.drupal.org/files/projects/"

  class Project < Thor
    attr_reader :branch, :codebase, :core, :path, :projects, :vc

    no_tasks do
      def initialize(args = {})
        @branch = args['branch']
        @codebase = args['codebase']
        @core = args['core']
        @path = "#{args['codebase']}/#{args['path']}"
        @projects = args['projects']
        @vc = args['vc']
        @vc_path = args['path']
      end

      def feed(project)
        "#{DRUPAL_PRJ_FEED}#{project}/#{core}"
      end

      def hacked?(project, existing)
        self.clean("#{path}/#{project}")
        link = self.build_link(project, existing)
        Download.new.fetch(link)
        self.extract(Download.new.path(link)) if self.verify(project, link, existing)
        repo = self.build_vc(project)
        changes = Repo.new(repo).st(true)
        if changes.empty? == false
          return !Confirm.new("Proceed?").yes?
        else
          return false
        end
      end

      def latest?(latest, existing, project)
        if Gem::Dependency.new('', "~> #{latest}").match?('', "#{existing}")
          say("#{project} is already at the latest version (#{latest}).", :yellow)
          return true
        else
          return false
        end
      end

      def build_link(project, version)
        DRUPAL_DL_LINK + "#{project}-#{version}.tar.gz"
      end

      def dl
        changes = []
        projects.each do |x, y|
          md5, version = self.release(x)
          if y.empty? == false
            if !self.hacked?(x, y) && !self.latest?(version, y, x)
              proceed = true
            else
              proceed = false
            end
          else
            proceed = true
          end
          if proceed
            self.clean("#{path}/#{x}")
            link = self.build_link(x, version)
            Download.new.fetch(link)
            # TODO: retry download after failed download verification
            self.extract(Download.new.path(link)) if self.verify(x, link)
            if vc == true
              repo = self.build_vc(x)
              changes += self.vc_up(repo)
            else
              say("#{x} added to codebase but changes are not yet under version control.", :yellow)
            end
          else
            self.clean("#{path}/#{x}")
            repo = self.build_vc(x)
            Repo.new(repo).co
          end
        end
        if changes.empty? == false
          repo = self.build_vc()
          self.vc_push(repo)
        end
      end

      def build_vc(x = '')
        repo = {}
        repo['codebase'] = codebase
        repo['path'] = @vc_path
        repo['branch'] = branch
        repo['project'] = x
        return repo
      end

      def vc_co(args)
        Repo.new(args).co
      end

      def vc_up(args)
        g = Repo.new(args)
        info = g.info
        changes = []
        msg = "Committing #{args['project']} on #{info['current_branch']} branch..."
        Msg.new(msg).format
        changes = g.commit("#{args['path']}/#{args['project']}")
        if changes.empty? == false
          say("  [done]", :green)
        else
          puts "\nNo changes to commit for #{args['project']}"
        end
        return changes
      end

      def vc_push(args)
        g = Repo.new(args)
        info = g.info
        msg = "Pushing all changes to #{info['remotes'][0]}..."
        Msg.new(msg).format
        g.push
        say("  [done]", :green)
      end

      def verify(x, file, version='')
        md5, version = self.release(x, version)
        if md5 == Digest::MD5.file(Download.new.path(file)).hexdigest
          return true
        else
          say("Verification failed for #{x} download!", :red)
          exit
        end
      end

      def release(project, version='')
        feed = self.feed(project)
        Download.new.fetch(feed)
        xml = File.open(Download.new.path(feed))
        doc = Nokogiri::XML(xml)
        releases = {}
        if version.empty? == false
          doc.xpath('//releases//release').each do |item|
            if item.at_xpath('version').content == version
              releases[item.at_xpath('mdhash').content] = item.at_xpath('version').content
            end
          end
        else
          doc.xpath('//releases//release').each do |item|
            if !item.at_xpath('version_extra')
              releases[item.at_xpath('mdhash').content] = item.at_xpath('version').content
            end
          end
        end
        if releases.nil?
          doc.xpath('//releases//release').each do |item|
            releases[item.at_xpath('mdhash').content] = item.at_xpath('version').content
          end
        end
        return releases.first
      end

      def clean(arg)
        FileUtils.rm_r arg if File.directory?(arg)
      end

      def extract(archive)
        Gem::Package::TarReader.new( Zlib::GzipReader.open archive ) do |tar|
          dst = nil
          tar.each do |entry|
            if entry.full_name == TAR_LONGLINK
              dst = File.join path, entry.read.strip
              next
            end
            dst ||= File.join path, entry.full_name
            if entry.directory?
              FileUtils.rm_rf dst unless File.directory? dst
              FileUtils.mkdir_p dst, :mode => entry.header.mode, :verbose => false
            elsif entry.file?
              FileUtils.rm_rf dst unless File.file? dst
              File.open dst, "wb" do |f|
                f.print entry.read
              end
              FileUtils.chmod entry.header.mode, dst, :verbose => false
            elsif entry.header.typeflag == '2' #Symlink!
              File.symlink entry.header.linkname, dst
            end
            dst = nil
          end
        end
      end
    end
  end
end

