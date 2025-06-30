class Karabou < Formula
  desc "CLI for managing Karabiner Elements Complex Modifications"
  homepage "https://github.com/pravin-sivabalan/karabou-cli"
  url "https://github.com/pravin-sivabalan/karabou-cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "629c7bc0aac0c6c28593a4e0c34dc725f9d3f3028331b28c1a20c10c7e251409"
  license "MIT"

  depends_on :xcode => ["14.0", :build]
  depends_on :macos

  def install
    # Ensure we're in the right directory
    system "swift", "package", "resolve"
    system "swift", "build", "--configuration", "release", "--disable-sandbox"
    
    # Install the binary
    bin.install ".build/release/KarabouCLI"
    bin.install_symlink "KarabouCLI" => "karabou"
  end

  test do
    system "#{bin}/karabou", "--help"
  end
end 