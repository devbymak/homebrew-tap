cask "network-monitor" do
  version "0.2.0"
  sha256 "8ccec6c93367611cc644228e27e1abb98a2934b6d45820fbc297157b4fa6deb9"

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
