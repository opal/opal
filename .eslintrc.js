module.exports = {
  "env": {
    "browser": true,
    "node": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": 3
  },
  "rules": {
    "no-unused-vars": ["error", {
      "varsIgnorePattern": "(\$(\$|\$\$|yield|post_args|[a-z])|self)",
      "argsIgnorePattern": "(\$(\$|\$\$|yield|post_args|[a-z])|self)",
    }],
    "no-extra-semi": "off",
    "no-empty": "off",
    "no-unreachable": "off",
    "no-cond-assign": "off",
    "no-prototype-builtins": "off",
    "no-constant-condition": ["error", { "checkLoops": false }],
    "no-useless-escape": "off",
    "no-fallthrough": ["error", { "commentPattern": "raise|no-break" }],
    "no-regex-spaces": "off",
    "no-control-regex": "off",
  },
  "globals": {
    "ArrayBuffer": "readonly",
    "DataView": "readonly",
    "globalThis": "readonly",
    "Opal": "readonly",
    "Promise": "readonly",
    "Proxy": "readonly",
    "Reflect": "readonly",
    "Uint8Array": "readonly",
    "WeakRef": "readonly",
    "Map": "readonly",
  }
};
