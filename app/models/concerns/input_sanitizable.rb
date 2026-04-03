module InputSanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_text_inputs
  end

  private

  def sanitize_text_inputs
    attributes.each do |key, value|
      next unless value.is_a?(String)
      sanitized = ActionController::Base.helpers.strip_tags(value)
      sanitized = sanitized.strip
      write_attribute(key, sanitized)
    end
  end
end
