# frozen_string_literal: true

class JavascriptLintingService
  class << self
    def start_command(path)
      "npx eslint #{path} -f json --no-eslintrc -c .eslintrc.yml" # прописать конфиг
    end

    def lint_messages_count(json)
      json.pluck('errorCount').sum
    end

    def serialize_errors(json)
      files_with_errors = json.filter { |file| file['messages'].any? }
      files_with_errors.map do |file|
        errors = file['messages'].map do |error|
          {
            message: error['message'],
            rule: error['ruleId'],
            position: "#{error['line']}:#{error['column']}"
          }
        end
        file_path = file['filePath']
        { file_path:, errors: }
      end
    end
  end
end
