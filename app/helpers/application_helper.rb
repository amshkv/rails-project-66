# frozen_string_literal: true

module ApplicationHelper
  include AuthConcern

  def han(model, attribute)
    model.to_s.classify.constantize.human_attribute_name(attribute)
  end
end
