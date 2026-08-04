import replace from 'rollup-plugin-re'

export default [
  {
    input: 'src/index.js',
    output: {
      file: 'src/index.cjs',
      format: 'cjs',
    },
    external: ['fs', 'glob', 'os', 'path', 'unxhr', 'util']
  },
  {
    input: 'src/index.js',
    output: {
      file: 'src/index.mjs',
      format: 'es',
    },
    plugins: [
      replace({
        patterns: [
          {
            // string or regexp
            test: 'import \'./nodejs.js\'',
            // string or function to replaced with
            replace: '',
          }
        ]
      }),
    ]
  }
]
