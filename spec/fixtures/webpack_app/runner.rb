require 'opal/cli_runners/chrome'
puts `yarn exec webpack -- --config=webpack/production.js`
chrome = Opal::CliRunners::Chrome.new({})
chrome.run(File.read(File.join(__dir__, 'public/assets/application.js')), nil)
