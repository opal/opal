# frozen_string_literal: true

require 'opal/nodes/call'
require 'json'
require 'opal/builder/import'

module Opal
  module Nodes
    class CallNode
      # Adds an `import` statement and returns a value
      # glob = Opal::Raw.import("glob", :default)
      #
      # The `what` argument denotes what do we want to import. For ESM:
      # - `:default`       => import _internal from "x" (default value)
      # - `:*`             => import * as _internal from "x"
      # - `:none`          => import "x";
      # - `:anything_else` => import { anything_else as _internal } from "x"
      # For CJS:
      # - `:default`       => require("x") (default value)
      # - `:*`             => require("x")
      # - `:none`          => require("x")
      # - `:anything_else` => require("x")["anything_else"]
      add_special :import, const: :"Opal::Raw" do
        argumentize do |from, what = :default|
          compiler.imports << Builder::Import.new(from: from, what: what, relative: from.start_with?("./"))
          push "Opal.imports[#{"#{from}/#{what}".to_json}]"
        end
      end

      # Adds a dynamic `import` statement and returns a value
      # # await: true
      # glob = Opal::Raw.dynimport("glob", :default).__await__
      #
      # Warning - this may (or may not!) return a Promise, you need to manually await it!
      #
      # The `what` argument denotes what do we want to import. For ESM:
      # - `:default`       => import("x").then(_mod => _mod.default) (default value)
      # - `:*`             => import("x")
      # - `:none`          => import("x").then(() => nil)
      # - `:anything_else` => import("x").then(_mod => _mod.anything_else)
      # For CJS:
      # (mode of operation the same as for regular import)
      add_special :dynimport, const: :"Opal::Raw" do
        argumentize do |from, what = :default|
          if compiler.esm?
            case what
            when :default
              push("import(#{from.to_json}).then(_mod => _mod.default)")
            when :*
              push("import(#{from.to_json})")
            when :none
              push("import(#{from.to_json}).then(() => nil)")
            else
              push("import(#{from.to_json}).then(_mod => _mod[#{what.to_json}])")
            end
          else
            case what
            when :default, :*
              push("require(#{from.to_json})")
            when :none
              push("(require(#{from.to_json}),nil)")
            else
              push("require(#{from.to_json})[#{what.to_json}]")
            end
          end
        end
      end

      # TODO
      add_special :export, const: :"Opal::Raw" do
      end
    end
  end
end
