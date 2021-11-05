const SourceMapConsumer = require('source-map').SourceMapConsumer
const path = require('path')
const fs = require('fs')
const root = `${__dirname}/..`
const results = JSON.parse(fs.readFileSync(`${root}/tmp/lint/result.json`, 'utf8'))
const bufferFrom = require('buffer-from');
const puts = (string = '') => process.stdout.write(`${string}\n`)
const retrieveSourceMapURL = (fileData) => {
  var re = /(?:\/\/[@#][\s]*sourceMappingURL=([^\s'"]+)[\s]*$)|(?:\/\*[@#][\s]*sourceMappingURL=([^\s*'"]+)[\s]*(?:\*\/)[\s]*$)/mg;
  var matches = fileData.match(re);
  return matches[matches.length - 1];
}

let count = 0

results.forEach(
  ({filePath, messages}) => {
    if (messages.length === 0) {return}

    const sourceMappingURL = retrieveSourceMapURL(fs.readFileSync(filePath, 'utf8'))
    const rawData = sourceMappingURL.split(',', 2)[1]
    const sourceMapData = bufferFrom(rawData, "base64").toString();
    const consumer = new SourceMapConsumer(sourceMapData);

    messages.forEach((error) => {
      const original = consumer.originalPositionFor({ line: error.line, column: error.column })
      count++

      puts()
      puts(`* ${error.message}`)
      if (error.ruleId) puts(`  - Read more: https://eslint.org/docs/rules/${error.ruleId}`)
      ;(error.suggestions || []).forEach((suggestion) => puts(`  - Suggestion: ${suggestion.desc}`))
      puts(`  - Compiled: ${path.relative(root, filePath)}:${error.line}:${error.column}`)
      puts(`  - Original: ${original.source}:${original.line}:${original.column}`)
    })
  }
)

puts(`\nFailed with ${count} error${count === 1 ? '' : 's'}.`)
process.exit(count || 1)
