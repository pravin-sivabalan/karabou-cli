# Karabou CLI

A CLI tool for managing Karabiner Elements Complex Modifications quickly and easily.

## Installation

### Homebrew (Recommended)

```bash
# Add the tap (using existing repository)
brew tap pravin-sivabalan/karabou-cli

# Install karabou
brew install karabou
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/pravin-sivabalan/karabou-cli.git
cd karabou-cli

# Build the project
swift build --configuration release

# Install to your system
cp .build/release/KarabouCLI /usr/local/bin/karabou
```

### Problem

I use the Karabiner Elements Complex Modifiers to open my apps. However, it is a pain to add these modifiers. Currently it means finding the app's file path or bundle identifier, then changing
the JSON configuration, and then restarting the app. I want this to be a lot easier.

### Solution

This project introduces a CLI for adding Karabiner Complex Modfications quickly. To start with it only supports adding open app actions. When adding an app, it
fuzzy searches amongst your apps to fuzzy find the app file path. It can also search amongst the actively running apps to check the package name.

It will also restart the Karabiner Elements application so that the update configuration update takes place ([karabiner documentation](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)).

### Unsupported

* non-MacOS Platforms
* Actions other than app opens
* Key-code validation

### Usage

The CLI supports three actions:

#### Add Action
Add a new key mapping to open an application:
```bash
karabou add --key-code z --app-search-query "Google Chrome"
```

#### Remove Action
Remove an existing key mapping:
```bash
karabou remove --key-code z
```

#### List Action
List all karabou-managed key mappings:
```bash
karabou list
```

#### Options
* `--modifier`: Key modifier (default: `right_command`)
* `--config-path`: Path to Karabiner configuration file (default: `~/.config/karabiner/karabiner.json`)

#### Examples
```bash
# Add a mapping for Command+Z to open Chrome
karabou add --key-code z --app-search-query "Chrome"

# Add a mapping with specific modifier
karabou add --key-code x --app-search-query "VSCode" --modifier right_command

# Remove a mapping
karabou remove --key-code z

# List all mappings
karabou list

# Use custom config path
karabou list --config-path ~/my-karabiner.json
``` 

### Bugs
- [ ] The karabiner app opens after restarts. Ideally this doesn't happen.
- [ ] Remove dependency on Karabiner for mappings.