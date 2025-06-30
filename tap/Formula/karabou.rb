class Karabou < Formula
  desc "CLI for managing Karabiner Elements Complex Modifications"
  homepage "https://github.com/pravin-sivabalan/karabou-cli"
  url "https://github.com/pravin-sivabalan/karabou-cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "YOUR_SHA256_HERE"
  license "MIT"

  depends_on :xcode => ["14.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "--configuration", "release"
    bin.install ".build/release/KarabouCLI"
    bin.install_symlink "KarabouCLI" => "karabou"
  end

  test do
    system "#{bin}/karabou", "--help"
  end
end 