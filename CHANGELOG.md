## Edge

*   Move Date out of opal.rb loading, as it is part of stdlib not corelib.

*   Fix for defining methods inside metaclass, or singleton_class scopes.

## 0.3.38 2013-02-13

*   Add Native module used for wrapping objects to forward calls as native
    calls.

*   Support method_missing for all objects. Feature can be enabled/disabled on
    Opal::Processor.

*   Hash can now use any ruby object as a key.

*   Move to Sprockets based building via `Opal::Processor`.
