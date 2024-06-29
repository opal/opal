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
        argumentize(perhaps_use: 'Opal::Raw.dynimport') do |from, what = :default|
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
        from, what = *args.children
        if compiler.esm?
          if what.type == :sym
            case what.children.first
            when :default
              next push 'import(', from, ').then(_mod => _mod.default)'
            when :*
              next push 'import(', from, ')'
            when :none
              next push 'import(', from, ').then(() => nil)'
            end
          end
          push 'import(', from, ').then(_mod => _mod[', what, '])'
        else
          if what.type == :sym
            case what.children.first
            when :default, :*
              next push("require(#{from.to_json})")
            when :none
              next push("(require(#{from.to_json}),nil)")
            end
          end
          push 'require(', from, ')[', what, ']'
        end
      end

      # TODO
      add_special :export, const: :"Opal::Raw" do
      end
    end
  end
end
