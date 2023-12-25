# frozen_string_literal: true

require 'open3'

module RepositoryCheckUtils
  def self.clone_repository(url, path)
    clone_command = "git clone #{url} #{path}"

    _, exit_status = Open3.popen3(clone_command) { |_stdin, stdout, _stderr, wait_thr| [stdout.read, wait_thr.value] }

    exit_status.exitstatus
  end

  def self.get_last_commit_id(path)
    cmd = "git -C #{path} rev-parse HEAD"

    commit_id, = Open3.popen3(cmd) { |_stdin, stdout, _stderr, wait_thr| [stdout.read, wait_thr.value] }

    commit_id
  end

  def self.start_lint_command(cmd)
    result, exit_status = Open3.popen3(cmd) { |_stdin, stdout, _stderr, wait_thr| [stdout.read, wait_thr.value] }
    [result, exit_status.exitstatus]
  end

  def self.remove_repository_dir(path)
    rm_command = "rm -rf #{path}"
    Open3.popen3(rm_command) { |_stdin, stdout, _stderr, wait_thr| [stdout.read, wait_thr.value] }
  end
end
