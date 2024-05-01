# frozen_string_literal: true

require 'opal/deprecations'
require 'opal/watcher'
require 'json'

# Opal::SimpleServer is a very basic Rack server for Opal assets, it relies on
# Opal::Builder and Ruby corelib/stdlib. It's meant to be used just for local
# development.
#
# For a more complete implementation see opal-sprockets (Rubygems) or
# opal-webpack (NPM).
#
# @example (CLI)
#   rackup -ropal -ropal/simple_server -b 'Opal.append_path("app"); run Opal::SimpleServer.new'
#   ... or use the Server runner ...
#   opal -Rserver app.rb
class Opal::RackHandler

  def initialize(app, options = {})
    @app = app
    @prefix = options.fetch(:prefix, 'assets')
    @mount = options.fetch(:mount, @prefix)
    @mount = @mount[1..-1] if @mount.start_with?("/")
    @app_dir = options.fetch(:app_dir, 'app')
    Opal.append_path(@app_dir)
    @builder = options.fetch(:builder, nil)
    @hot_updates = options.fetch(:hot_updates, true)
    if @hot_updates
      hot_ruby = options.fetch(:hot_ruby, nil)
      if hot_ruby
        @hot_javascript = Opal::Compiler.new(hot_ruby, requirable: false, file: "hot_ruby.rb").compile
      else
        @hot_javascript = options.fetch(:hot_javascript, '')
      end
    else
      @hot_javascript = ''
    end
    @transformations = []
    @index_path = nil
    @last_build_time = @start_time
    @builders = {}
    @development = !%w[production test].include?(ENV['RACK_ENV'])
    @watcher = Opal::Watcher.new(@app_dir)
  end

  def development?
    @development
  end

  def append_path(path)
    @transformations << [:append_paths, path]
  end

  def call(env)
    case env['PATH_INFO']
    when %r{\A/#{@mount}/(.*?)\.m?js(/.*)?\z}
      path, rest = Regexp.last_match(1), Regexp.last_match(2)&.delete_prefix('/')
      call_js(path, rest)
    when "/#{@mount}/__updates__"
      if development?
        poll_updates
      else
        [404, {}, ["/#{@mount}/__updates__ not found!"]]
      end
    else
      @app.call(env)
    end
  end

  def call_js(path, rest)
    asset = fetch_asset(path, rest)
    append_polling_code(asset) if development? && @hot_updates
    [
      200,
      { 'content-type' => 'application/javascript' },
      @directory ? [asset[:data]] : [asset[:data], "\n", asset[:map].to_data_uri_comment],
    ]
  end

  def builder(path)
    case @builder
    when Opal::Builder
      builder = @builder
    when Proc
      if @builder.arity == 0
        builder = @builder.call
      else
        builder = @builder.call(path)
      end
    else
      builder = Opal::Builder.new
      builder = apply_builder_transformations(builder)
      builder.build(path.gsub(/(\.(?:rb|m?js|opal))*\z/, ''))
    end

    @esm = builder.compiler_options[:esm]
    @directory = builder.compiler_options[:directory]

    builder
  end

  # Only cache one builder at a time
  def cached_builder(path, uncache: false)
    @builders = {} if uncache || @builders.keys != [path]
    @builders[path] ||= builder(path)
  end

  def apply_builder_transformations(builder)
    @transformations.each do |type, *args|
      case type
      when :append_paths
        builder.append_paths(*args)
      end
    end
    builder
  end

  def fetch_asset(path, rest)
    builder = cached_builder(path)
    if @directory
      { data: builder.compile_to_directory(single_file: rest) }
    else
      {
        data: builder.to_s,
        map: builder.source_map
      }
    end
  end

  def compile_ruby(file)
    source = File.binread(file)
    module_file = file[(@app_dir.size + 1)..-1]
    compiler = Opal::Compiler.new(source, requirable: true, file: module_file)
    compiler.compile
  end

  def poll_updates
    updates = @watcher.poll_updates
    data = {}
    if ((updates[:modified].size + updates[:added].size) > 5) || updates[:removed].any?
      # trigger page reload
      data[:reload_page] = true
    else
      # compile changes
      updates[:modified].each do |path|
        if path.end_with?('.rb')
          data[:modified] ||= []
          data[:modified] << compile_ruby(path)
        end
      end
      updates[:added].each do |path|
        if path.end_with?('.rb')
          data[:added] ||= []
          data[:added] << compile_ruby(path)
        end
      end
    end
    [200, { 'content-type' => 'application/json' }, [JSON.dump(data)]]
  end

  def append_polling_code(asset)
    asset[:data] << <<~JAVASCRIPT
      // Opal hot reloading code
      if (typeof(globalThis.Opal) === "object" && typeof(globalThis.Opal.hmr_polling) === "undefined") {
        globalThis.Opal.hmr_polling = true;
        function get_module_name_from_js(js) {
          let start_index = 'Opal.modules[\\"'.length;
          let end_index = js.indexOf('"', start_index);
          return js.substr(start_index, end_index - start_index);
        }
        async function poll_updates() {
          let response = await fetch("/#{@mount}/__updates__", { cache: "no-cache", keepalive: true, method: "GET", priority: "low", redirect: "error" });
          let updates = await response.json();
          if (updates.reload_page === true) {
            location.reload();
          }
          let i, js, opal_module_name;
          let mod_mod = [];
          let add_mod = [];
          if (typeof Opal.require_table !== "undefined" && Opal.require_table['corelib/module']) {
            if (updates.modified) {
              for (i = 0; i < updates.modified.length; i++) {
                js = updates.modified[i];
                opal_module_name = get_module_name_from_js(js)
                console.log('Opal hot updating ', opal_module_name);
                try {
                  window.eval(js);
                  mod_mod.push(opal_module_name);
                } catch (e) { console.error(e); }
              }
            }
            if (updates.added) {
              for (i = 0; i < updates.modified.length; i++) {
                js = updates.added[i];
                opal_module_name = get_module_name_from_js(js)
                console.log('Opal hot adding ', opal_module_name);
                try {
                  window.eval(js);
                  add_mod.push(opal_module_name);
                } catch (e) { console.error(e); }
              }
            }
          }
          try {
            let mod_name;
            for (i = 0; i < mod_mod.length; i ++) {
              mod_name = mod_mod[i];
              if (Opal.require_table[mod_name]) { Opal.load.call(Opal, mod_name); }
              else { Opal.require.call(Opal, mod_name); }
            }
            for (i = 0; i < add_mod.length; i ++) {
              mod_name = add_mod[i];
              Opal.require.call(Opal, mod_name);
            }
            if ((updates.modified && updates.modified.length > 0) || (updates.added && updates.added.length > 0)) {
              // execute user supplied code
              function hot_javascript() {
                #{@hot_javascript}
              }
              hot_javascript();
            }
          } catch (e) { console.error(e); return; }
          setTimeout(poll_updates, 1000);
        }
        setTimeout(poll_updates, 2000); // give some time for app initialization
      }
    JAVASCRIPT
  end
end
