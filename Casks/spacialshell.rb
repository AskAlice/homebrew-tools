cask "spacialshell" do
  version "0.4.2"
  sha256 "727814de8b5dcf1a6903f3b7adbad6042a162ee993d03eee934f917f052aeee9"

  url "https://github.com/AskAlice/SpacialShell-MacOS/releases/download/v#{version}/SpacialShell-#{version}.dmg"
  name "SpacialShell"
  desc "Spatial tiling window manager"
  homepage "https://askalice.github.io/SpacialShell-MacOS/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Sparkle updates the app in place (#58); brew upgrade skips it unless --greedy.
  auto_updates true

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
