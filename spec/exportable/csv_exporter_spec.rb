require "spec_helper"

describe 'Export CSV' do

  before(:each) do
    create(:exportable_model)
  end

  it "responds to export_csv" do
    ExportableModel.class_eval{ exportable }
    expect(ExportableModel.respond_to? 'export_csv').to be_truthy 
  end

  it "exports csv data" do
    ExportableModel.class_eval{ exportable }
    csv = CSV.parse(ExportableModel.export_csv, headers: true)
    expect(csv.first['field_string']).to eq 'sample string' 
  end

  it "exports properly encode data" do
    ExportableModel.class_eval{ exportable }
    ExportableModel.create!(field_string: 'sample st,ring')
    csv = CSV.parse(ExportableModel.export_csv, headers: true)
    expect(csv[-1]['field_string']).to eq 'sample st,ring' 
  end

  it "exports properly quote data" do
    ExportableModel.class_eval{ exportable }
    ExportableModel.create!(field_string: '0123')
    quoter = Proc.new do |field|
      field = '"' + field + '"' if field == '0123'
      field
    end
    options = { csv_options: { quote_char: '', write_converters: [quoter] } }
    csv = ExportableModel.export_csv(options)
    expect(csv).to include('"0123"')
  end

  it "exports csv data with 'only' option" do
    ExportableModel.class_eval{ exportable only: [:field_string] }
    csv = CSV.parse(ExportableModel.export_csv, headers: true)
    expect(csv.headers).not_to include('field_text')  
  end

  it "exports csv data with 'except' option" do
    ExportableModel.class_eval{ exportable except: [:field_string] }
    csv = CSV.parse(ExportableModel.export_csv, headers: true)
    expect(csv.headers).not_to include('field_string')  
  end

  it "exports csv data with 'header' option" do
    ExportableModel.class_eval{ exportable header: false }
    csv = CSV.parse(ExportableModel.export_csv, headers: true)
    expect(csv.headers).not_to include('field_string')  
  end

  it "exports csv data with 'reference' option" do
    ExportableModel.class_eval{ exportable only: [:field_date, :field_text] }
    model = ExportableModel.create!(field_date: Date.new(2021, 1, 4), field_text: 'this is it')
    formatted_date = model.field_date.strftime('%D')
    reference = instance_double('exportable_model', field_text: model.field_text.upcase, field_date: formatted_date)
    csv = CSV.parse(ExportableModel.export_csv(reference: reference), headers: true)

    expect(csv[-1]['field_date']).to eq('01/04/21')
    expect(csv[-1]['field_text']).to eq(reference.field_text)
  end

  it "exports csv data with 'methods' option" do
    ExportableModel.class_eval do  
      exportable methods: [:title]
      def title
        field_string.upcase
      end
    end
    csv = CSV.parse(ExportableModel.export_csv, headers: true)    
    expect(csv.headers).to include('title')  
  end

  it "has option preference on utility method" do
    ExportableModel.class_eval{ exportable only: [:field_string]}
    csv = CSV.parse(ExportableModel.export_csv(only: [:field_string, :field_text]), headers: true)    
    expect(csv.headers).to include('field_text')  
  end

  it 'validates arguments' do
    ExportableModel.class_eval{ exportable only: :field_string}
    expect{ExportableModel.export_csv}.to raise_error(ArgumentError)
    ExportableModel.class_eval{ exportable only: [:field_string]}
    expect{ExportableModel.export_csv methods: :title}.to raise_error(ArgumentError) 
  end 

end 