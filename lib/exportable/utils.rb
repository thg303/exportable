module Exportable
  # Utiity methods used for gem
  module Utils
    # Compute exportable options after overriding preferences
    def get_export_options(model, options)
      default_options = { only: model.attribute_names.map(&:to_sym),
                          except: [],
                          methods: [],
                          csv_options: default_csv_options,
                          header: true }
      options = default_options.merge(options)
      unless options[:only].is_a?(Array) && options[:except].is_a?(Array) && options[:methods].is_a?(Array)
        raise ArgumentError, 'Exportable: Expecting Array type for field options'
      end
      fields = options[:only] - options[:except] + options[:methods]
      csv_options = options[:csv_options].is_a?(Hash) ? options[:csv_options] : default_options[:csv_options]
      { fields: fields, header: options[:header], reference_model: options[:reference], csv_options: csv_options }
    end

    def safe_model(model, options)
      model = options[:reference_model] if options[:reference_model].present?
      return model if model.respond_to?(:each)

      return model.where(nil) if model.respond_to?(:where)

      [model]
    end

    def default_csv_options
      has_zero_before_numbers = /\A0[\d]*\z/
      has_comma = /[,]+/
      default_number_quoter = Proc.new do |field|
        field = '"' + field + '"' if field.match?(has_comma) || field.match?(has_zero_before_numbers)
        field
      end
      { quote_char: '',
        write_converters: [default_number_quoter] }
    end
  end
end
