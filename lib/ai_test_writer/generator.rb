require "erb"
require "json"

module AiTestWriter
  class Generator
    def initialize(source_path, test_path)
      @source_path = source_path
      @test_path = test_path
      @client = AiApiClient.new
    end

    def generate
      generated_code = @client.call(body)

      new_test_file = File.open(@test_path, "wb")
      new_test_file.write(generated_code)
      new_test_file.close
    end

    private

    def body
      source_code = File.read(@source_path)

      messages = from_template(:new_test_file)
      messages << { role: "user", content: source_code }

      messages
    end

    def from_template(template_name)
      path = File.join(File.dirname(__FILE__), "prompts", "#{template_name}.json.erb")
      template = File.read(path)
      result = ERB.new(template).result(binding)
      JSON.parse(result)
    end
  end
end
