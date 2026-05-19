"use strict";

const js = require("@eslint/js");
const globals = require("globals");

module.exports = [
  {
    ignores: [
      "core/main/client/lib/**",
      "modules/**",
      "node_modules/**",
      "extensions/admin_ui/media/javascript-min/**",
      "**/*.min.js",
    ],
  },
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 5,
      sourceType: "script",
      globals: {
        ...globals.browser,

        // BeEF
        beef: "readonly",
        beef_init: "readonly",

        // jQuery
        $: "readonly",
        jQuery: "readonly",
        $j: "readonly",

        // Libraries
        MobileEsp: "readonly",
        evercookie: "readonly",
        swfobject: "readonly",

        // Browser-specific (old IE / old Firefox)
        XDomainRequest: "readonly",
        MozWebSocket: "readonly",
        clipboardData: "readonly",

        // Debug
        isDebug: "readonly",
      },
    },
  },
];
