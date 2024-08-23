# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ai_test_writer"

# require "minitest/autorun"
require "minitest/spec"
require "webmock/minitest"
# require all *.rb files from lib directory
Dir[File.join(__dir__, "lib", "**", "*.rb")].each { |file| require file }
