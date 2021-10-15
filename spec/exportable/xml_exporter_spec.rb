describe 'Export XML' do

  before(:each) do
    create_list(:exportable_model, 3)
  end

  it 'responds to export_xml' do
    ExportableModel.class_eval{ exportable }
    expect(ExportableModel.respond_to? 'export_xml').to be_truthy 
  end

  it "exports xml data with 'export_xml' method" do
    ExportableModel.class_eval{ exportable }
    output = Nokogiri::XML.parse(ExportableModel.all.export_xml)
    expect(output.xpath('//exportable_model').length).to eq 3
  end

  it "exports xml data with 'export' method" do
    ExportableModel.class_eval{ exportable }
    output = Nokogiri::XML.parse(ExportableModel.all.export(:xml))
    expect(output.xpath('//exportable_model').length).to eq 3
  end
  
  it "exports xml data with 'only' option" do
    ExportableModel.class_eval{ exportable only: [:field_string] }
    output = Nokogiri::XML.parse(ExportableModel.all.export_xml)
    expect(output.xpath('//field_text').length).to eq 0
  end

  it "exports xml data with 'except' option" do
    ExportableModel.class_eval{ exportable except: [:field_string] }
    output = Nokogiri::XML.parse(ExportableModel.all.export_xml)
    expect(output.xpath('//field_string').length).to eq 0
    expect(output.xpath('//field_text').length).to eq 3
  end

  it "exports xml data with 'reference' option" do
    ExportableModel.class_eval{ exportable only: [:field_date, :field_text] }
    model = ExportableModel.create!(field_date: Date.new(2021, 1, 4), field_text: 'this is it')
    formatted_date = model.field_date.strftime('%D')
    klass = instance_double('klass', table_name: 'exportable_models')
    model_name = instance_double('model_name', element: 'ExportableModel')
    reference = instance_double('exportable_model', class: klass, model_name: model_name,
                                field_text: model.field_text.upcase, field_date: formatted_date)
    output = Nokogiri::XML.parse(ExportableModel.export_xml(reference: reference))

    expect(output.xpath('//field_date').text).to eq('01/04/21')
    expect(output.xpath('//field_text').text).to eq(reference.field_text)
  end
  
  it "exports xml data with 'methods' option" do
    ExportableModel.class_eval do  
      exportable methods: [:title]
      def title
        field_string.upcase
      end
    end
    output = Nokogiri::XML.parse(ExportableModel.all.export_xml)
    expect(output.xpath('//title').length).to eq 3 
  end

end 
