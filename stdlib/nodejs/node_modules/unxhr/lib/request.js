const http = require('http')
const https = require('https')

function doRequest (options) {
  const { ssl, encoding, requestOptions } = options
  return new Promise((resolve, reject) => {
    let responseText = ''
    const responseBinary = []
    const httpRequest = ssl ? https.request : http.request
    const req = httpRequest(requestOptions, function (response) {
      if (encoding !== 'binary') {
        response.setEncoding(encoding)
      }
      response.on('data', function (chunk) {
        if (encoding === 'binary') {
          responseBinary.push(chunk)
        } else {
          responseText += chunk
        }
      })
      response.on('end', function () {
        const result = {
          error: null,
          data: { statusCode: response.statusCode, headers: response.headers }
        }
        if (encoding === 'binary') {
          result.data['binary'] = Buffer.concat(responseBinary)
        } else {
          result.data['text'] = responseText
        }
        resolve(result)
      })
      response.on('error', function (error) {
        reject(error)
      })
    }).on('error', function (error) {
      reject(error)
    })
    req.end()
  })
}

(async () => {
  try {
    const args = process.argv.slice(2)
    const options = {}
    for (let j = 0; j < args.length; j++) {
      const arg = args[j]
      if (arg.startsWith('--ssl=')) {
        options.ssl = arg.slice('--ssl='.length) === 'true'
      } else if (arg.startsWith('--encoding=')) {
        options.encoding = arg.slice('--encoding='.length)
      } else if (arg.startsWith('--request-options=')) {
        options.requestOptions = JSON.parse(arg.slice('--request-options='.length))
      }
    }
    const result = await doRequest(options)
    console.log(JSON.stringify(result))
  } catch (e) {
    console.log(JSON.stringify({ 'error': e }))
  }
})()

