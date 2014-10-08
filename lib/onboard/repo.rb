#!/usr/bin/env ruby

require 'fileutils'
require 'git'
require 'pathname'
require 'thor'

require_relative 'patch'

module Onboard
  class Repo < Thor
    attr_reader :g, :path, :codebase, :project

    no_tasks do
      def initialize(repo)
        @codebase = repo['codebase']
        @g = prepare(repo)
        @path = repo['path']
        @project = repo['project']
      end

      def changed(list, patch_file, patch)
        return false if list.empty?
        say('CHANGED FILES:', :yellow)
        list.each do |x|
          puts g.diff('HEAD', x).patch
          patch_file << g.diff('HEAD', x).patch if patch
        end
      end

      def deleted(list, patch_file, patch)
        return false if list.empty?
        say('DELETED FILES:', :yellow)
        list.each do |x|
          say(x, :red)
          patch_file << g.diff('--', x).patch if patch
        end
      end

      def untracked(list, patch_file, patch)
        return false if list.empty?
        say('UNTRACKED FILES:', :yellow)
        list.each do |x|
          say(x, :red)
          if patch
            g.add(x)
            patch_file << g.diff('HEAD', x).patch
          end
        end
      end

      def repo_status
        all = {}
        all['changed'] = []
        all['deleted'] = []
        all['untracked'] = []
        g.status.changed.keys.each { |file| all['changed'].push(file.to_s) unless g.diff('HEAD', file).patch.empty? }
        g.status.deleted.keys.each { |file| all['deleted'].push(file.to_s) }
        g.status.untracked.keys.each { |file| all['untracked'].push(file.to_s) }
        all
      end

      def st(patch = false)
        patch_file = Patch.new.open(project) if patch
        # TODO: figure out why g.status.changed.keys.each is returning unchanged files
        all = repo_status
        changed(all['changed'], patch_file, patch)
        deleted(all['deleted'], patch_file, patch)
        untracked(all['untracked'], patch_file, patch)
        Patch.new.close(patch_file)
        all.empty? ? false : true
      end

      def co
        g.checkout_file('HEAD', path)
      end

      def info
        repo = {}
        repo['current_branch'] = g.current_branch
        repo['remotes'] = g.remotes
        repo
      end

      def prepare(args)
        Git.open((Pathname.new(args['codebase'])).to_s)
      end

      def commit(path)
        project = File.basename(path)

        changes = []
        g.status.changed.keys.each { |x| changes.push x unless g.diff('HEAD', x).patch.empty? }
        g.status.deleted.keys.each { |x| changes.push x }
        g.status.untracked.keys.each { |x| changes.push x }

        if changes.empty? == false
          g.add(codebase, :all => true)
          g.commit("Add #{project}")
        end

        changes
      end

      def push
        g.push
      end
    end
  end
end
