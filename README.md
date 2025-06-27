# Karabiner CLI

### Problem

I use the Karabiner Elements Complex Modifiers to open my apps. However, it is a pain to add these modifiers. Currently it means finding the app's file path or bundle identifier, then opening changing
the JSON configuration, and then restarting the app. I want this to be a lot easier.

### Solution

This project introduces a CLI for adding Karabiner Complex Modfications quickly. To start with it only supports adding open app actions. When adding an app, it
fuzzy searches amongst your apps to fuzzy find the app file path. It can also search amongst the actively running apps to check the package name.

It will also restart the Karabiner Elements application so that the update configuration update takes place ([karabiner documentation](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)).

### Unsupported

* Actions other than app opens
* Key-code validation

### Design Notes
* KarabinerConfig: Responsible for updating the KarabinerConfig. It will read/write to the configuration file and restart the app.
* AppFetcher: Gets a list of apps either through the looking through files or getting a list of active apps.
FuzzyMatcher: Searches for a target string, with fuzzy matching, in a list of strings.
* Path for config : ~/.config/karabiner/assets/complex_modifications