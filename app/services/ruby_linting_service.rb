# frozen_string_literal: true

class RubyLintingService
  class << self
    def start_command(path)
      "bundle exec rubocop #{path} --format json"
    end

    def lint_messages_count(json)
      json['summary']['offense_count']
    end

    def serialize_errors(json)
      files = json['files']
      files_with_errors = files.filter { |file| file['offenses'].any? }
      files_with_errors.map do |file|
        errors = file['offenses'].map do |error|
          {
            message: error['message'],
            rule: error['cop_name'],
            position: "#{error['location']['line']}:#{error['location']['column']}"
          }
        end
        file_path = file['path']
        { file_path:, errors: }
      end
    end
  end
end
