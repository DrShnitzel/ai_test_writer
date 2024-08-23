# frozen_string_literal: true

require_relative "ai_test_writer/version"
require_relative "ai_test_writer/generator"
require "optparse"

module AiTestWriter
  def self.call
    options = {}
    parser = OptionParser.new

    parser.on("--source-file-path PATH", "Path to source file") do |value|
      options[:source_file_path] = value
    end
    parser.on("--test-file-path PATH", "Path to new test file") do |value|
      options[:test_file_path] = value
    end
    parser.on("--test-command COMMAND", "Command to run tests") do |value|
      options[:test_command] = value
    end
    parser.on("--test-command-dir DIR", "Directory to run tests") do |value|
      options[:test_command_dir] = value
    end
    parser.on("--max-iterations N", "Maximum number of iterations") do |value|
      options[:max_iterations] = value
    end
    parser.on("--additional-prompt PROMPT", "Add additional prompt to requests") do |value|
      options[:additional_prompt] = value
    end
    parser.parse!

    puts options

    Generator.new(**options).generate
  end
end
