class Karabou < Formula
  desc "CLI for managing Karabiner Elements Complex Modifications"
  homepage "https://github.com/pravin-sivabalan/karabou-cli"
  url "https://github.com/pravin-sivabalan/karabou-cli/releases/download/v0.0.5/KarabouCLI"
  sha256 "8929ca18f8e4929ff7460bf68aa4ab14e458d7676fa613c6e9bddde1190de48e"
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