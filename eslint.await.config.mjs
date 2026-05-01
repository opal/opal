import config from "./eslint.config.mjs";

export default config.map((entry) => {
  if (!entry.languageOptions) return entry;

  return {
    ...entry,
    languageOptions: {
      ...entry.languageOptions,
      ecmaVersion: 8,
      parserOptions: {
        ...entry.languageOptions.parserOptions,
        allowReserved: false,
      },
    },
  };
});
