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

      def patch_empty?(file)
        g.diff('HEAD', file).patch.empty?
      end

      def build_changed_array(s = false)
        changed_array = []
        g.status.changed.keys.each { |file| changed_array.push(file.tap{|a| a.to_s if s}) unless patch_empty?(file) }
        changed_array
      end

      def build_deleted_array(s = false)
        deleted_array = []
        g.status.deleted.keys.each { |file| deleted_array.push(file.tap{|a| a.to_s if s}) }
        deleted
      end

      def build_untracked_array(s = false)
        untracked_array = []
        g.status.untracked.keys.each { |file| untracked_array.push(file.tap{|a| a.to_s if s}) }
        untracked_array
      end

      def repo_status
        all = {}
        all['changed'] = build_changed_array(true)
        all['deleted'] = build_deleted_array(true)
        all['untracked'] = build_untracked_array(true)
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
        changes << build_changed_array << build_deleted_array << build_untracked_array

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
