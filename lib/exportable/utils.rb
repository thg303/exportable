module Exportable
  # Utiity methods used for gem
  module Utils
    # Compute exportable options after overriding preferences
    def get_export_options(model, options)
      default_options = { only: model.attribute_names.map(&:to_sym),
                          except: [],
                          methods: [],
                          header: true }
      options = default_options.merge(options)
      unless options[:only].is_a?(Array) && options[:except].is_a?(Array) && options[:methods].is_a?(Array)
        raise ArgumentError, 'Exportable: Expecting Array type for field options'
      end
      fields = options[:only] - options[:except] + options[:methods]
      { fields: fields, header: options[:header], reference_model: options[:reference] }
    end

    def safe_model(model, options)
      model = options[:reference_model] if options[:reference_model].present?
      return model if model.respond_to?(:each)

      return model.where(nil) if model.respond_to?(:where)

      [model]
    end
  end
end
