#!/usr/bin/env ruby

# TODO: Watch for updates to rugged that enable git push
require 'git'
require 'pathname'

module Onboard
  class Repo
    attr_reader :g, :path, :branch

    def initialize(repo)
      @codebase = repo['codebase']
      @g = self.prepare(repo)
      @path = repo['path']
      @branch = repo['branch']
    end

    def info
      repo = {}
      repo['current_branch'] = g.current_branch
      repo['remotes'] = g.remotes
      return repo
    end

    def prepare(args)
      repo = Git.open((Pathname.new(args['codebase'])).to_s)
      selection = args['branch'].empty? ? repo.current_branch : args['branch']
      repo.branch(selection).checkout
      return repo
    end

    def update
      project = File.basename(path)

      changes = []
      g.status.changed.keys.each { |x| changes.push x }
      g.status.deleted.keys.each { |x| changes.push x }
      g.status.untracked.keys.each { |x| changes.push x }

      if changes.nil? == false
        g.add(path, :all=>true)
        g.commit("Add #{project}")
      else
        puts "No changes to commit for #{project}"
      end
    end

    def push
      g.push
    end
  end
end
