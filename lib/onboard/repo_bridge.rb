# encoding: utf-8

require 'thor'

require_relative 'msg'
require_relative 'repo'

module Onboard
  class RepoBridge < Thor
    attr_reader :args, :g, :info

    no_tasks do
      def initialize(args = {})
        @args = args
        @g = Repo.new(args)
        @info = g.info
      end

      def co
        g.co
      end

      def up
        msg = "Committing #{args['project']} on #{info['current_branch']} branch..."
        Msg.new(msg).format
        changes = g.commit("#{args['path']}/#{args['project']}")
        if changes.empty? == false
          say('  [done]', :green)
        else
          puts "\nNo changes to commit for #{args['project']}"
        end
        changes
      end

      def push
        msg = "Pushing all changes to #{info['remotes'][0]}..."
        Msg.new(msg).format
        g.push
        say('  [done]', :green)
      end
    end
  end
end
