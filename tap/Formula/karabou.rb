class Karabou < Formula
  desc "CLI for managing Karabiner Elements Complex Modifications"
  homepage "https://github.com/pravin-sivabalan/karabou-cli"
  url "https://github.com/pravin-sivabalan/karabou-cli/archive/refs/tags/v0.0.50.0.50.0.50.0.50.0.50.0.50.0.50.0.50.0.5.tar.gz"
  sha256 "8929ca18f8e4929ff7460bf68aa4ab14e458d7676fa613c6e9bddde1190de48e"
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