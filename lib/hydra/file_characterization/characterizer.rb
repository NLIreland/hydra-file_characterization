require 'hydra/file_characterization/exceptions'
require 'open3'
require 'active_support/core_ext/class/attribute'

module Hydra::FileCharacterization
  class Characterizer
    include Open3

    class_attribute :tool_path

    attr_reader :filename
    def initialize(filename, tool_path = nil)
      @filename = filename
      @tool_path = tool_path
    end

    def call
      unless File.exist?(filename)
        raise Hydra::FileCharacterization::FileNotFoundError.new("File: #{filename} does not exist.")
      end

      if tool_path.respond_to?(:call)
        tool_path.call(filename)
      else
        internal_call
      end
    end

    def tool_path
      @tool_path || self.class.tool_path || convention_based_tool_name
    end

    protected

    def convention_based_tool_name
      self.class.name.split("::").last.downcase
    end

    def internal_call
      stdin, stdout, stderr, wait_thr = popen3(command)
      begin
        out = stdout.read
        err = stderr.read
        exit_status = wait_thr.value
        raise "Unable to execute command \"#{command}\"\n#{err}" unless exit_status.success?
        out
      ensure
        stdin.close
        stdout.close
        stderr.close
      end
    end

    def command
      raise NotImplementedError, "Method #command should be overriden in child classes"
    end
  end
end
