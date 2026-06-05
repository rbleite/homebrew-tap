# homebrew-tap

Personal Homebrew tap for tools maintained by [@rbleite](https://github.com/rbleite).

## Install

```bash
brew tap rbleite/tap
```

## Available formulae

### drive-xray

Index drives, find duplicates, track changes over time — for people
with many USB drives, bioinformatics files, and photo collections.

```bash
brew install drive-xray
dx --version          # → dx 1.0.0 (schema v5 · hash v2)
dx --help
```

Source repo: https://github.com/rbleite/drive-xray

The brew formula installs only the `dx` CLI binary (universal arm64 +
x86_64). The Streamlit UI is a separate concern that needs a Python
venv — clone the source repo and follow the README for the UI setup.

## License

Each formula references the license of the upstream project.
This tap itself is Apache-2.0.
