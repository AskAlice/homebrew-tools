cask "spacialshell" do
  version "0.4.1"
  sha256 "393202586a5397bb338978d48032b82630a080fef52ba3c508233387b02566c0"

  url "https://github.com/AskAlice/SpacialShell-MacOS/releases/download/v#{version}/SpacialShell-#{version}.dmg"
  name "SpacialShell"
  desc "Spatial tiling window manager"
  homepage "https://askalice.github.io/SpacialShell-MacOS/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "SpacialShell.app"
  binary "#{appdir}/SpacialShell.app/Contents/MacOS/spacialctl"

  uninstall quit: "sh.emu.SpacialShell"

  zap trash: [
    "~/.config/spacial-shell",
    "~/Library/Application Support/SpacialShell",
    "~/Library/Caches/sh.emu.SpacialShell",
    "~/Library/HTTPStorages/sh.emu.SpacialShell",
    "~/Library/Preferences/sh.emu.SpacialShell.plist",
  ]

  caveats <<~EOS
    SpacialShell runs without a Dock icon and needs the Accessibility permission:
      System Settings > Privacy & Security > Accessibility
    Quitting SpacialShell restores your windows.
  EOS
end
