cask "fan-control" do
  version "0.4.2"
  sha256 "50e196113e4a1e4b5ee569322eb05a6b42f8ab94acc3577b6d4bdf8684c646fc"

  url "https://github.com/devbymak/fan-control/releases/download/v#{version}/FanControl-#{version}.zip"
  name "Fan Control"
  desc "Menu bar temperatures and fan control for Apple silicon Macs"
  homepage "https://github.com/devbymak/fan-control"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Fan Control.app"
  binary "#{appdir}/Fan Control.app/Contents/MacOS/fancontrol"

  # Same steps as ./build.sh --install: fan control runs only from a root-owned copy of the app's binary, which
  # must match the installed app, so every install and upgrade replaces it. Asks for your password once.
  postflight_steps do
    # Fan Control is distributed outside Apple's notarization service.
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Fan Control.app"]
    run "/bin/mkdir", args: ["-p", "/Library/PrivilegedHelperTools"], sudo: true
    run "/usr/bin/install",
        args: ["-o", "root", "-g", "wheel", "-m", "755", "{{appdir}}/Fan Control.app/Contents/MacOS/fancontrol",
               "/Library/PrivilegedHelperTools/local.fancontrol.helper"],
        sudo: true
    # Password-free fan control: lets only you run only this helper, only in the app's two forms. Checked with
    # visudo before installing, since a broken sudoers file stops sudo working. Written in a folder only root can
    # enter, so nothing running as you can change it between check and install.
    run "/bin/sh", args: ["-c", <<~'SH', "sh", "{{user}}"], sudo: true
      set -eu
      case "$1" in ""|*[!A-Za-z0-9._-]*) echo "Unexpected user name: $1" >&2; exit 1 ;; esac
      folder=$(/usr/bin/mktemp -d /private/var/tmp/fancontrol.XXXXXX)
      trap '/bin/rm -rf "$folder"' EXIT
      helper=/Library/PrivilegedHelperTools/local.fancontrol.helper
      printf '%s ALL=(root) NOPASSWD: /usr/bin/env -i %s --control *, /usr/bin/env -i %s --restore\n' \
        "$1" "$helper" "$helper" > "$folder/rule"
      if /usr/sbin/visudo -cqf "$folder/rule"; then
        /usr/bin/install -o root -g wheel -m 440 "$folder/rule" /etc/sudoers.d/fancontrol
      else
        echo "Could not set up password-free fan control; Fan Control will ask for your password each time." >&2
      fi
    SH
  end

  # Quitting hands the fans back to macOS before anything is removed.
  uninstall quit:   "local.fancontrol",
            delete: [
              "/etc/sudoers.d/fancontrol",
              "/Library/PrivilegedHelperTools/local.fancontrol.helper",
              "/var/db/local.fancontrol.lock",
            ]

  zap trash: "~/Library/Preferences/local.fancontrol.plist"
end
