module Exportable
  module ExportMethods
    # Module to handle only CSV exporting
    module CsvExporter
      include Exportable::Utils

      Exportable.formats << :csv

      def export_csv(options = {})
        export_options = get_export_options(self, @options.merge(options))
        Exporter.new(safe_model(self, export_options)).export(export_options)
      end

      # Exporter class for CSV Exporter
      class Exporter
        require 'csv'

        def initialize(model)
          @model = model
        end

        def export(options)
          CSV.generate(options[:csv_options]) do |csv|
            csv << options[:fields].map(&:to_s) if options[:header]
            @model.each do |record|
              csv << options[:fields].map { |attr| record.send(attr).to_s }
            end
          end
        end
      end
    end
  end
end
