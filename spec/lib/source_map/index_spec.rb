require 'support/source_map_helper'

RSpec.describe Opal::SourceMap::Index do
  include SourceMapHelper

  specify '#as_json' do
    builder = Opal::Builder.new
    builder.build_str('foo', 'bar.rb')
    map = builder.source_map
    expect(map.as_json).to be_a(Hash)
    expect(map.as_json(ignored: :options)).to be_a(Hash)
  end

  let(:builder) do
    builder = Opal::Builder.new
    builder.build_str(
      "    jsline1();\n"+
      "    jsline2();\n"+
      "    jsline3();",
      'js_file.js'
    )
    builder.build_str(
      "  rbline1\n"+
      "  rbline2\n"+
      "  rbline3",
      'rb_file.rb'
    )
    builder.build_str(
      "\n"+
      "\n"+
      "\n"+
      "    jsline4();\n"+
      "    jsline5();\n"+
      "    jsline6();",
      'js2_file.js'
    )
    builder.build_str(
      "\n"+
      "\n"+
      "\n"+
      "  rbline4\n"+
      "  rbline5\n"+
      "  rbline6",
      'rb2_file.rb'
    )
    builder
  end

  let(:compiled) { builder.to_s }
  let(:source_map) { builder.source_map }
  let(:mappings) { source_map.send(:mappings) }

  it 'points to the correct source line' do
    # To debug this stuff can be useful to print out all
    # the sources with #inspect_source:
    #
    #   p :compiled
    #   inspect_source compiled
    #
    #   p :generated_code
    #   source_map.source_maps.each do |sub_source_map|
    #     p generated_code: sub_source_map.file
    #     inspect_source sub_source_map.generated_code
    #   end
    #

    expect('jsline1(').to be_mapped_to_line_and_column(0, 4, file: 'js_file.js', map: source_map, source: compiled)
    expect('jsline2(').to be_mapped_to_line_and_column(1, 4, file: 'js_file.js', map: source_map, source: compiled)
    expect('jsline3(').to be_mapped_to_line_and_column(2, 4, file: 'js_file.js', map: source_map, source: compiled)
    expect('$rbline1(').to be_mapped_to_line_and_column(0, 2, file: 'rb_file.rb', map: source_map, source: compiled)
    expect('$rbline2(').to be_mapped_to_line_and_column(1, 2, file: 'rb_file.rb', map: source_map, source: compiled)
    expect('$rbline3(').to be_mapped_to_line_and_column(2, 2, file: 'rb_file.rb', map: source_map, source: compiled)
    expect('jsline4(').to be_mapped_to_line_and_column(3, 4, file: 'js2_file.js', map: source_map, source: compiled)
    expect('jsline5(').to be_mapped_to_line_and_column(4, 4, file: 'js2_file.js', map: source_map, source: compiled)
    expect('jsline6(').to be_mapped_to_line_and_column(5, 4, file: 'js2_file.js', map: source_map, source: compiled)
    expect('$rbline4(').to be_mapped_to_line_and_column(3, 2, file: 'rb2_file.rb', map: source_map, source: compiled)
    expect('$rbline5(').to be_mapped_to_line_and_column(4, 2, file: 'rb2_file.rb', map: source_map, source: compiled)
    expect('$rbline6(').to be_mapped_to_line_and_column(5, 2, file: 'rb2_file.rb', map: source_map, source: compiled)
  end
end
