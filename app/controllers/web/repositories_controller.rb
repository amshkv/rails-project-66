# frozen_string_literal: true

class Web::RepositoriesController < Web::ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories
  end

  def new; end

  def create; end
end
