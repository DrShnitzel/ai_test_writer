# frozen_string_literal: true

require_relative "ai_test_writer/version"
require "optparse"

module AiTestWriter
  def self.call
    parser = OptionParser.new

    parser.on("--source-file-path", "Path to source file") do |value|
      source_file_path = value
    end
    parser.on("--test-file-path", "Path to new test file") do |value|
      test_file_path = value
    end
    parser.parse!

    Generator.new(source_file_path, test_file_path).generate
  end
end
