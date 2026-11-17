cask "network-monitor" do
  version "0.2.1"
  sha256 "52322386b83b77021725ba2ffef3588e271b09566d6d8a95ce31c9c4772644df"

  url "https://github.com/devbymak/network-monitor/releases/download/v#{version}/NetworkMonitor-#{version}.zip"
  name "Network Monitor"
  desc "Menu bar network speed, data usage and ping monitor"
  homepage "https://github.com/devbymak/network-monitor"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Network Monitor.app"

  postflight_steps do
    # Network Monitor is distributed outside Apple's notarization service.
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Network Monitor.app"]
  end

  # Quitting saves today's usage before the app is removed.
  uninstall quit: "local.networkmonitor"

  zap trash: [
    "~/Library/Application Scripts/local.networkmonitor",
    "~/Library/Containers/local.networkmonitor",
  ]
end
