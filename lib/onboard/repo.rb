#!/usr/bin/env ruby

require 'fileutils'
require 'git'
require 'pathname'
require 'thor'

module Onboard
  class Repo < Thor
    attr_reader :g, :path, :branch, :codebase, :project

    no_tasks do
      def initialize(repo)
        @codebase = repo['codebase']
        @g = self.prepare(repo)
        @path = repo['path']
        @branch = repo['branch']
        @project = repo['project']
      end

      def st(patch = false)
        changed = []
        deleted = []
        untracked = []

        if patch
          patches_dir = "/tmp/onboard/patches"
          unless File.directory?(patches_dir)
            FileUtils.mkdir_p(patches_dir)
          end
          patch_file = File.open( "#{patches_dir}/#{Time.now.to_i}_#{project}.patch","w" )
        end

        # TODO: figure out why g.status.changed.keys.each is returning 
        # unchanged files
        g.status.changed.keys.each { |file| changed.push(file.to_s) if !g.diff('HEAD', file).patch.empty? }
        g.status.deleted.keys.each { |file| deleted.push(file.to_s) }
        g.status.untracked.keys.each { |file| untracked.push(file.to_s) }
        all = changed + deleted + untracked

        if changed.empty? == false
          say('CHANGED FILES:', :yellow)
          changed.each do |x|
            puts g.diff('HEAD', x).patch
            if patch
              patch_file << g.diff('HEAD', x).patch
            end
          end
          puts ''
        end

        if deleted.empty? == false
          say('DELETED FILES:', :yellow)
          deleted.each do |x|
            say(x, :red)
            if patch
              patch_file << g.diff('--', x).patch
            end
          end
          puts ''
        end

        if untracked.empty? == false
          say('UNTRACKED FILES:', :yellow)
          untracked.each do |x|
            say(x, :red)
            if patch
              g.add(x)
              patch_file << g.diff('HEAD', x).patch
            end
          end
          puts ''
        end

        if patch
          patch_file.close
          Dir.foreach(patches_dir) do |item|
            file = "#{patches_dir}/#{item}"
            FileUtils.rm_r file if File.zero?(file)
          end
        end

        return all
      end

      def co
        g.checkout_file('HEAD', path)
      end

      def info
        repo = {}
        repo['current_branch'] = g.current_branch
        repo['remotes'] = g.remotes
        return repo
      end

      def prepare(args)
        Git.open((Pathname.new(args['codebase'])).to_s)
      end

      def commit(path)
        project = File.basename(path)

        changes = []
        g.status.changed.keys.each { |x| changes.push x if !g.diff('HEAD', x).patch.empty? }
        g.status.deleted.keys.each { |x| changes.push x }
        g.status.untracked.keys.each { |x| changes.push x }

        if changes.empty? == false
          g.add(codebase, :all=>true)
          g.commit("Add #{project}")
        end

        return changes
      end

      def push
        g.push
      end
    end
  end
end

