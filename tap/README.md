# Homebrew Tap for Karabou CLI

This is a Homebrew tap for the [Karabou CLI](https://github.com/pravin-sivabalan/karabou-cli) tool.

## Installation

```bash
# Add this tap
brew tap pravin-sivabalan/karabou-cli

# Install karabou
brew install karabou
```

## What is Karabou?

Karabou is a CLI tool for managing Karabiner Elements Complex Modifications quickly and easily. It allows you to:

- Add key mappings to open applications
- Remove existing key mappings  
- List all karabou-managed mappings
- Automatically restart Karabiner Elements when changes are made

## Usage

```bash
# Add a mapping for Command+Z to open Chrome
karabou add --key-code z --app-search-query "Chrome"

# List all mappings
karabou list

# Remove a mapping
karabou remove --key-code z
```

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later (for building from source)
- Karabiner Elements installed

## License

MIT License - see the [main repository](https://github.com/pravin-sivabalan/karabou-cli) for details. 