# frozen_string_literal: true

class OctokitClientStub
  def initialize(*); end

  def repos
    response = File.read('test/fixtures/files/repositories_response.json')
    JSON.parse(response)
  end

  def repo(_id)
    response = File.read('test/fixtures/files/repository_response.json')
    JSON.parse(response)
  end

  def create_hook(*); end
end
