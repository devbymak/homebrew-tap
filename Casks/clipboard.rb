cask "clipboard" do
  version "0.2.0"
  sha256 "d9f3131cae5e173f18f1e1418b7d1a65634f20c5804972946392380e18655d20"

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
