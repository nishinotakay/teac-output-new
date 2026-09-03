module IsoDateParams
  ISO_DATE_PATTERN = /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/
  FILTER_DATE_PARAM_KEYS = %i[start finish].freeze

  private

  def parse_iso_date(value)
    return unless value.kind_of?(String) && value.match?(ISO_DATE_PATTERN)

    Date.iso8601(value)
  rescue Date::Error
    nil
  end

  def invalid_iso_date_param_key
    FILTER_DATE_PARAM_KEYS.find do |key|
      params[key].present? && parse_iso_date(params[key]).nil?
    end
  end
end
