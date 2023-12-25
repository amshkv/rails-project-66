# frozen_string_literal: true

module RepositoryCheckUtilsStub
  def self.clone_repository(_, _)
    0
  end

  def self.get_last_commit_id(_)
    '5c59eef20d00261cb2fc265fe13a3e2d45633df0'
  end

  def self.start_lint_command(cmd)
    # NOTE: такая не совсем красивая логика сделана для проверки хекслет чека и другого языка, чтобы отдать нулевой статус для руби
    language = cmd.split.first == 'npx' ? 'javascript' : 'ruby'

    if language == 'javascript'
      result = File.read('test/fixtures/files/eslint_errors.json')
      [result, 666]
    else
      result = File.read('test/fixtures/files/rubocop_empty_errors.json')
      [result, 0]
    end
  end

  def self.remove_repository_dir(_); end
end
