import globals from "globals";
import js from "@eslint/js";
console.log(js.configs.recommended);

// "parserOptions": {
//   -    "ecmaVersion": 12
//   +    "ecmaVersion": 2020,
//      },
//      "rules": {
//        "no-unused-vars": ["error", {
//   @@ -35,5 +35,6 @@ module.exports = {
//        "Int32Array": "readonly",
//        "WeakRef": "readonly",
//        "Map": "readonly",
//   +    "BigInt": "readonly",


export default [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: "commonjs",
      globals: {
          ...globals.browser,
          ...globals.node,
          ...globals.es2020,
          Opal: "readonly",
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
