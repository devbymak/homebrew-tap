cask "clipboard" do
  version "0.2.1"
  sha256 "f7f3e7bfc80c50893beabc08dc0118b34ee8fe3a351f78b1eb42a3e449e3fe3c"

  url "https://github.com/devbymak/clipboard/releases/download/v#{version}/Clipboard-#{version}.zip"
  name "Clipboard"
  desc "Menu bar clipboard history that keeps text and images"
  homepage "https://github.com/devbymak/clipboard"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Clipboard.app"

  postflight_steps do
    # Clipboard is distributed outside Apple's notarization service.
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Clipboard.app"]
  end

  # Quitting saves the history before the app is removed.
  uninstall quit: "local.clipboard"

  # History, pins and preferences all live in the app's sandbox container.
  zap trash: "~/Library/Containers/local.clipboard"
end
