#!/usr/bin/env ruby

require 'git'

module Onboard
  class Source
    attr_reader :source, :ref

    def initialize(source, ref = 'master')
      @ref = ref
      @source = source
    end

    def git?
      !!(source =~ /\.git$/)
    end

    def archive?
      !!(source =~ /[\.gz|\.tar|\.tgz|\.zip]$/)
    end

    def subtree
      `git --work-tree="#{codebase}" --git-dir="#{codebase}"/.git subtree add --prefix "#{path}" "#{source}" "#{ref}" --squash`
    end
  end
end
