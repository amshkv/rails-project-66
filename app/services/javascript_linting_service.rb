# frozen_string_literal: true

class JavascriptLintingService
  class << self
    def start_command(path)
      "npx eslint #{path} -f json --no-eslintrc"
    end

    def lint_messages_count(json)
      json.pluck('errorCount').sum
    end

    def serialize_errors(json)
      json.map do |line|
        errors = line['messages'].map do |error|
          {
            message: error['message'],
            rule: error['ruleId'],
            position: "#{error['line']}:#{error['column']}"
          }
        end
        file_path = line['filePath']
        { file_path:, errors: }
      end
    end
  end
end
