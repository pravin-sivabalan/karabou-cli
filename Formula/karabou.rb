class Karabou < Formula
  desc "CLI for managing Karabiner Elements Complex Modifications"
  homepage "https://github.com/pravin-sivabalan/karabou-cli"
  url "https://github.com/pravin-sivabalan/karabou-cli/releases/download/v1.0.0/KarabouCLI"
  sha256 "YOUR_BINARY_SHA256_HERE"
  license "MIT"

  depends_on :macos

  def install
    # Install the pre-built binary
    bin.install "KarabouCLI"
    bin.install_symlink "KarabouCLI" => "karabou"
  end

  test do
    system "#{bin}/karabou", "--help"
  end
end 