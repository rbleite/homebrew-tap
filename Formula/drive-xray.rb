# Homebrew formula for drive-xray.
#
# Installs the universal `dx` binary (x86_64 + arm64 fat Mach-O) built
# from the source at https://github.com/rbleite/drive-xray.
#
# The Streamlit UI is intentionally NOT installed by brew — it needs a
# Python venv with streamlit/plotly/openpyxl that the user manages. The
# `dx` binary is the long-running engine that benefits from brew's
# system-wide install. To launch the UI, clone the repo and run
# `streamlit run app.py` (or `bash build_app.sh` for a .app launcher).
class DriveXray < Formula
  desc "Index drives + find duplicates + snapshots over time"
  homepage "https://github.com/rbleite/drive-xray"
  url "https://github.com/rbleite/drive-xray/releases/download/v1.5.1/dx-1.5.1-darwin-universal.tar.gz"
  sha256 "427d90cb4f207352ac2dcaa58f6907f8ec626f78e23d90dbfcc838e5335963de"
  license "Apache-2.0"
  # No `version` line: brew scans it from the URL, and `brew audit` rejects
  # stating it twice. It was right to — two places holding the same number is
  # how this formula came to advertise one version while shipping another.

  # The tarball already contains a universal binary; no per-arch split.
  depends_on macos: :big_sur

  def install
    bin.install "dx"
  end

  def caveats
    <<~EOS
      drive-xray installed the `dx` CLI.

      For the Streamlit UI, clone the repo and run a one-off launcher:
        git clone https://github.com/rbleite/drive-xray.git
        cd drive-xray
        python3 -m venv .venv
        .venv/bin/pip install streamlit openpyxl plotly
        .venv/bin/streamlit run app.py

      Or, for a clickable macOS .app in ~/Applications:
        cd drive-xray && bash build_app.sh

      Try the CLI first:
        dx --version
        dx index ~/Documents --label docs -x --db ~/docs.db
        dx dedupe ~/docs.db
    EOS
  end

  test do
    # Smoke test: version flag prints schema + hash protocol.
    # (v1.5.1 output: "dx 1.5.1" /
    #                 "schema:  v7 (path interning, one row per path)" /
    #                 "hash:    BLAKE2b v2 (head + middle + tail)")
    #
    # The schema number is asserted deliberately. This formula sat pinned to
    # v1.4.1 for a month after schema v7 shipped, so `brew install` was handing
    # out an engine that read migrated databases without complaining and
    # answered cross-drive duplicate searches with nothing at all. Pinning the
    # number here means a formula left behind again fails its own test.
    # `version` here is the one brew scanned from the URL, so the binary is
    # checked against the tarball we actually asked for, with no third copy of
    # the number to fall out of step.
    assert_match "dx #{version}", shell_output("#{bin}/dx --version")
    assert_match "BLAKE2b v2",    shell_output("#{bin}/dx --version")
    # The schema number IS hardcoded, deliberately. It has to be revisited by
    # a human when the schema moves, and that is the whole point: this line
    # said "v6" for a month after v7 shipped, so a formula handing out an
    # engine that could not read the current schema passed its own test.
    assert_match "v7",            shell_output("#{bin}/dx --version")

    # End-to-end: index a tiny tree, list the snapshot.
    (testpath/"data/a.txt").parent.mkpath
    (testpath/"data/a.txt").write "hello"
    (testpath/"data/b.txt").write "hello"
    system bin/"dx", "index", testpath/"data",
           "--db", testpath/"test.db", "--label", "test", "-x"
    out = shell_output("#{bin}/dx snapshot list #{testpath}/test.db")
    assert_match "test", out
  end
end
