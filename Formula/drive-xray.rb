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
  url "https://github.com/rbleite/drive-xray/releases/download/v1.4.0/dx-1.4.0-darwin-universal.tar.gz"
  sha256 "d3deb7a045841127e324e59c369675f8ad4ec4f068e9bcee052aeb2d77edd308"
  license "Apache-2.0"
  version "1.4.0"

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
        dx index ~/Documents --label docs -x
        dx dedupe ~/tools/drive-xray/docs.db
    EOS
  end

  test do
    # Smoke test: version flag prints schema + hash protocol.
    # (v1.4.0 output: "schema:  v6 (path interning + metadata)" /
    #                 "hash:    BLAKE2b v2 (head + middle + tail)")
    assert_match "v6",         shell_output("#{bin}/dx --version")
    assert_match "BLAKE2b v2", shell_output("#{bin}/dx --version")

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
