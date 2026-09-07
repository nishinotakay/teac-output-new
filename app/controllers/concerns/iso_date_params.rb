module IsoDateParams
  # params[key] が YYYY-MM-DD 形式でないときに投げる。呼び出し側で 400 にする
  class InvalidIsoDateParam < ArgumentError
    def initialize(key)
      super("#{key} は YYYY-MM-DD 形式で指定してください")
    end
  end

  ISO_DATE_PATTERN = /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/

  private

  # params[key] を Date にして返す。未指定（blank）は nil。
  # nil は「未指定」だけを意味する。形式不正は例外にするので、呼び出し側は nil を安全に「条件なし」と読める
  def iso_date_param(key)
    value = params[key]
    return nil if value.blank?
    raise InvalidIsoDateParam, key unless value.kind_of?(String) && value.match?(ISO_DATE_PATTERN)

    Date.iso8601(value)
  rescue Date::Error
    raise InvalidIsoDateParam, key
  end
end
