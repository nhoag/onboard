#!/usr/bin/env ruby

require 'git'
require 'pathname'
require 'thor'

require_relative 'msg'

module Onboard
  class Repo < Thor
    attr_reader :g, :path, :branch, :codebase, :projects

    no_tasks do
      def initialize(repo)
        @codebase = repo['codebase']
        @g = self.prepare(repo)
        @path = repo['path']
        @branch = repo['branch']
        @projects = repo['projects']
      end

      def st
        changed = []
        deleted = []
        untracked = []

        # TODO: figure out why g.status.changed.keys.each is returning 
        # unchanged files
        g.status.changed.keys.each { |file| changed.push(file.to_s) if !g.diff('HEAD', file).patch.empty? }
        g.status.deleted.keys.each { |file| deleted.push(file.to_s) }
        g.status.untracked.keys.each { |file| untracked.push(file.to_s) }
        all = changed + deleted + untracked

        if changed.empty? == false
          say('CHANGED FILES:', :yellow)
          changed.each { |z| puts g.diff('HEAD', z).patch }
          puts ''
        end

        if deleted.empty? == false
          say('DELETED FILES:', :yellow)
          deleted.each { |x| say(x, :red) }
          puts ''
        end

        if untracked.empty? == false
          say('UNTRACKED FILES:', :yellow)
          untracked.each { |y| say(y, :red) }
          puts ''
        end

        return all
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

      def update
        info = self.info
        changes = []
        projects.each do |x, y|
          msg = "Committing #{x} on #{info['current_branch']} branch..."
          Msg.new(msg).format
          changes = self.commit("#{path}/#{x}")
          if changes.empty? == false
            say("  [done]", :green)
          else
            puts "\nNo changes to commit for #{x}"
          end
        end
        if changes.empty? == false
          msg = "Pushing all changes to #{info['remotes'][0]}..."
          Msg.new(msg).format
          self.push
          say("  [done]", :green)
        end
      end

      def commit(path)
        project = File.basename(path)

        changes = []
        g.status.changed.keys.each { |x| changes.push x if !g.diff('HEAD', x).patch.empty? }
        g.status.deleted.keys.each { |x| changes.push x }
        g.status.untracked.keys.each { |x| changes.push x }

        if changes.empty? == false
          g.add(path, :all=>true)
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

