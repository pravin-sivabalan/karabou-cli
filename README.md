# Karabiner CLI


### Problem

I use the Karabiner Elements Complex Modifiers to open my apps. However, it is a pain to add open apps modifiers in the app and invovles directly modifying JSON. 


### Solution

This project introduces a CLI for adding Karabiner Complex Modfications quickly. To start with it only supports adding open app actions. When adding an app, it
fuzzy searches amongst your apps to fuzzy find the app file path. It can also search amongst the actively running apps to check the package name.

It will also restart the Karabiner Elements application so that the update configuration update takes place.

### Unsupported

Non app open applications
Key-code validation


### Entity

KarabinerConfig: Responsible for updating the KarabinerConfig. It will read/write to the configuration file and restart the app.
AppFetcher: Gets a list of apps either through the looking through files or getting a list of active apps.
FuzzyMatcher: Searches for a target string, with fuzzy matching, in a list of strings.

Path: ~/.config/karabiner/assets/complex_modifications