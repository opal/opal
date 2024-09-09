import globals from "globals";
import js from "@eslint/js";

export default [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 12,
      sourceType: "commonjs",
      globals: {
          ...globals.browser,
          ...globals.node,
          ArrayBuffer: "readonly",
          DataView: "readonly",
          globalThis: "readonly",
          Opal: "readonly",
          Promise: "readonly",
          Proxy: "readonly",
          Reflect: "readonly",
          Uint8Array: "readonly",
          Int32Array: "readonly",
          WeakRef: "readonly",
          Map: "readonly",
      },
    },

    rules: {
      "no-unused-vars": ["error", {
          varsIgnorePattern: "($($|$$|yield|post_args|[a-z])|self)",
          argsIgnorePattern: "($($|$$|yield|post_args|[a-z])|self)",
      }],

      "no-extra-semi": "off",
      "no-empty": "off",
      "no-unreachable": "off",
      "no-cond-assign": "off",
      "no-prototype-builtins": "off",

      "no-constant-condition": ["error", {
          checkLoops: false,
      }],

      "no-useless-escape": "off",

      "no-fallthrough": ["error", {
          commentPattern: "raise|no-break",
      }],

      "no-regex-spaces": "off",
      "no-control-regex": "off",
    },
  }
];
