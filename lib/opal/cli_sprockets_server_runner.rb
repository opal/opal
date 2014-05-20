# ##
# # SPROCKETS
#
# def sprockets
#   server.sprockets
# end
#
# def server
#   @server ||= Opal::Server.new do |s|
#     load_paths.each do |path|
#       s.append_path path
#     end
#     s.main = File.basename(filename, '.rb')
#   end
# end
#
# def set_processor_options(compiler_options)
#   compiler_options.each do |name, value|
#     Opal::Processor.send("#{name}=", value)
#   end
# end
#
# set_processor_options(compiler_options)

