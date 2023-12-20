# frozen_string_literal: true

module RepositoryCheckUtilsStub
  def self.clone_repository(_, _)
    0
  end

  def self.start_lint_command(_)
    result = File.read('test/fixtures/files/eslint_errors.json')
    [result, 666]
  end

  def self.remove_repository_dir(_); end
end
