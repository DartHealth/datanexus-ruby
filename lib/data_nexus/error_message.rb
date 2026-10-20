# frozen_string_literal: true

module DataNexus
  # Builds a human-readable message from a parsed API error body
  #
  # The API's `errors` value takes one of three shapes: an object with a
  # `detail` (and, for coded failures, a `code`), an object mapping field
  # names to messages, or a list of request validation errors.
  #
  module ErrorMessage
    module_function

    # @param body [Hash, nil] Parsed error response body
    # @param default [String] Message to use when the body has none
    # @return [String]
    def from(body, default)
      return default unless body.is_a?(Hash)

      body[:error] || body[:message] || from_errors(body[:errors]) || default
    end

    # @param errors [Hash, Array, String, nil]
    # @return [String, nil]
    def from_errors(errors)
      message =
        case errors
        when String then errors
        when Hash then from_hash_errors(errors)
        when Array then errors.map { |error| from_validation_error(error) }.join('; ')
        end

      message unless message.to_s.empty?
    end

    # @param errors [Hash] A coded error or detail, or messages keyed by field name
    # @return [String]
    def from_hash_errors(errors)
      return errors[:detail] if errors[:detail]

      errors.map { |field, messages| "#{field} #{Array(messages).join(', ')}" }.join('; ')
    end

    # @param error [Hash, String] One request validation error
    # @return [String]
    def from_validation_error(error)
      return error.to_s unless error.is_a?(Hash)

      detail = error[:detail] || error[:title]
      pointer = error.dig(:source, :pointer)
      pointer ? "#{pointer}: #{detail}" : detail.to_s
    end
  end
end
