require "spec_helper"

describe 'Export XLS' do

  before(:each) do
    create(:exportable_model)
  end

  it "responds to export_csv" do
    ExportableModel.class_eval{ exportable }
    expect(ExportableModel.respond_to? 'export_xls').to be_truthy 
  end

  it "exports xls data" do
    ExportableModel.class_eval{ exportable }
    sheet = write_xls
    expect(sheet.row(1)[1]).to eq 'sample string'
  end
  
  it "exports xls data with 'only' option" do
    ExportableModel.class_eval{ exportable only: [:field_string] }
    sheet = write_xls
    expect(sheet.row(0)).not_to include('field_text')  
  end

  it "exports xls data with 'except' option" do
    ExportableModel.class_eval{ exportable except: [:field_string] }
    sheet = write_xls
    expect(sheet.row(0)).not_to include('field_string')  
  end

  it "exports xls data with 'header' option" do
    ExportableModel.class_eval{ exportable header: false }
    sheet = write_xls
    expect(sheet.row(0)).not_to include('field_string')  
  end

  it "exports xls data with 'reference' option" do
    ExportableModel.class_eval{ exportable only: [:field_date, :field_text] }
    model = ExportableModel.create!(field_date: Date.new(2021, 1, 4), field_text: 'this is it')
    formatted_date = model.field_date.strftime('%D')
    reference = instance_double('exportable_model', field_text: model.field_text.upcase, field_date: formatted_date)
    sheet = write_xls reference: reference

    expect(sheet.row(1)[0]).to eq('01/04/21')
    expect(sheet.row(1)[1]).to eq(reference.field_text)
  end

  it "exports xls data with 'methods' option" do
    ExportableModel.class_eval do  
      exportable methods: [:title]
      def title
        field_string.upcase
      end
    end
    sheet = write_xls
    expect(sheet.row(0)).to include('title')  
  end

  it "has option preference on utility method" do
    ExportableModel.class_eval{ exportable only: [:field_string]}
    sheet = write_xls only: [:field_string, :field_text]
    expect(sheet.row(0)).to include('field_text')  
  end

end 
