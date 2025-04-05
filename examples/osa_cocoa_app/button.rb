# inspired by https://github.com/tylergaw/js-osx-app-examples/tree/master/HandleBtnClick.app/
# backtick_javascript: true
require "osascript/support"

ObjC.import("Cocoa")
# `debugger`

begin
height = 120
width = 250

textFieldLabel = NSTextField.alloc.initWithFrame(NSMakeRect(25, (height - 40), 200, 24))
textFieldLabel.stringValue = "Change this text:"
textFieldLabel.drawsBackground = false
textFieldLabel.editable = false
textFieldLabel.bezeled = false
textFieldLabel.selectable = true

textField = NSTextField.alloc.initWithFrame(NSMakeRect(25, (height - 65), 200, 24))
textField.stringValue = "New Label Text"

# If no superclass is provided, NSObject is subclassed.
ObjC.registerSubclass({
	name: "AppDelegate",
	methods: {
		"btnClickHandler:" => {
			types: ["void", ["id"]],
			implementation: proc do |sender|
				textFieldLabel.stringValue = textField.stringValue
      end
		}
	}
})

appDelegate = AppDelegate.alloc.init

styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask

window = NSWindow.alloc.initWithContentRectStyleMaskBackingDefer(
	NSMakeRect(0, 0, width, height),
	styleMask.to_s,
	NSBackingStoreBuffered.to_s,
	false
)

btn = NSButton.alloc.initWithFrame(NSMakeRect(25, (height - 100), 200, 25))
btn.title = "Update Label"
btn.bezelStyle = NSRoundedBezelStyle
btn.setButtonType(NSMomentaryLightButton)
# NOTE: See NSButton docs for info on target/action
btn.target = appDelegate
btn.action = "btnClickHandler:"
btn.keyEquivalent = "\r" # Enter key

window.contentView.addSubview(btn)
window.contentView.addSubview(textField)
window.contentView.addSubview(textFieldLabel)

window.center
window.title = "Handling Button Click Example"
window.makeKeyAndOrderFront(window)

rescue e
	STDERR.puts e
end
