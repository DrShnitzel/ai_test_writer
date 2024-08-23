require "erb"
require "json"
require "open3"
require "ai_test_writer/ai_api_client"

module AiTestWriter
  class Generator
    def initialize(source_file_path:, test_file_path:, test_command:, max_iterations:, additional_prompt:)
      @source_path = source_file_path
      @test_path = test_file_path
      @test_command = test_command
      @max_iterations = max_iterations.to_i || 0
      @additional_prompt = additional_prompt
      @client = AiApiClient.new
    end

    def generate
      generated_code = @client.call(body)

      new_test_file = File.open(@test_path, "wb")
      new_test_file.write(generated_code)
      new_test_file.close

      test_file_and_fix_errors
    end

    private

    def test_file_and_fix_errors(iterations = 0)
      puts "testing attempt #{iterations + 1}.."
      command = "#{@test_command} #{@test_path}"
      puts "executing command: #{command}"
      stdout, stderr, status = Open3.capture3(command)
      puts stdout
      puts status
      return if status.success?

      if iterations >= @max_iterations
        puts "Max iterations reached"
        # os.remove(test_path)
        return
      end

      fix_errors(stdout)

      test_file_and_fix_errors(iterations + 1)
    end

    def fix_errors(errors)
      # This is where the AI will fix the errors

      source_code = File.read(@source_path)
      test_code = File.read(@test_path)

      messages = prompt_template(:fix_errors)
      messages << { role: "user", content: source_code }
      messages << { role: "user", content: test_code }
      messages << { role: "user", content: errors }
      messages << { role: "user", content: test_template(:minitest) }
      messages << { role: "user", content: @additional_prompt }

      new_test_code = @client.call(messages)
      new_test_file = File.open(@test_path, "wb")
      new_test_file.write(new_test_code)
      new_test_file.close
    end



    def body
      source_code = File.read(@source_path)

      messages = prompt_template(:new_test_file)
      messages << { role: "user", content: test_template(:minitest) }
      messages << { role: "user", content: source_code }
      messages << { role: "user", content: @additional_prompt }

      messages
    end

    def prompt_template(template_name)
      path = "lib/ai_test_writer/prompts/#{template_name}.json.erb"
      template = File.read(path)
      result = ERB.new(template).result(binding)
      JSON.parse(result)
    end

    def test_template(template_name)
      path = "lib/ai_test_writer/templates/#{template_name}.rb.erb"
      File.read(path)
    end
  end
end
