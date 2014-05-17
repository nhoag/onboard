#!/usr/bin/env ruby

# TODO: Watch for updates to rugged that enable git push
require 'git'
require 'pathname'

module Onboard
  class Repo
    attr_reader :docroot, :path

    def initialize(docroot, path)
      @docroot = docroot
      @path = path
    end

    def update
      prj_root = Pathname.new(docroot)
      workdir = prj_root.parent.to_s
      project = File.basename(path)

      g = Git.open(workdir)
      g.branch('master').checkout

      changes = []
      g.status.changed.keys.each { |x| changes.push x }
      g.status.deleted.keys.each { |x| changes.push x }
      g.status.untracked.keys.each { |x| changes.push x }

      if changes.nil? == false
        g.add(path, :all=>true)
        g.commit("Adds #{project}")
        g.push
      else
        puts "No changes to commit for #{project}"
      end
    end
  end
end