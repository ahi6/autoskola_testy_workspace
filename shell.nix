# https://github.com/DioxusLabs/dioxus/discussions/3710

{pkgs ? import <nixpkgs> {}}: let
  overrides = builtins.fromTOML (builtins.readFile ./rust-toolchain.toml);
in
  pkgs.callPackage (
    {
    atkmm,
    cairo,
    gcc,
    gdk-pixbuf,
    glib,
    gtk3,
    mkShell,
    openssl,
    pango,
    pkg-config,
    rustup,
    rustPlatform,
    stdenv,
    webkitgtk_4_1,  # for javascriptcoregtk-rs-sys
    xdotool,        # for libxdo
    }:
      mkShell {
        strictDeps = true;
        nativeBuildInputs =
          [
            pkgs.rustc
            pkgs.cargo
            pkgs.cargo-binstall
            pkgs.rustfmt
            pkgs.dioxus-cli
            pkgs.glib
	    pkgs.pkg-config
	    pkgs.openssl
	    pkgs.gcc
            pkgs.wasm-bindgen-cli_0_2_100
            pkgs.lld_20
            rustPlatform.bindgenHook
            pkgs.tailwindcss
	    pkgs.nodejs
          ]
          ++ [
            pkgs.python3
            pkgs.libGL
            pkgs.libGLU
          ]
          ++ [
            pkgs.xorg.libxcb
            pkgs.xorg.libXcursor
            pkgs.xorg.libXrandr
            pkgs.xorg.libXi
            pkgs.pkg-config
	    pkgs.gst_all_1.gstreamer
          ];
        # libraries here
        buildInputs = with pkgs; [
          nodejs
          rustc
          cargo
          rustfmt
          rust-analyzer
          libz
          clippy
          xorg.libX11
          wayland
          libxkbcommon
          trunk
          atkmm
      cairo
      gdk-pixbuf
      glib
      gtk3
      pango
      webkitgtk_4_1
      xdotool
      gst_all_1.gstreamer
        ];
        RUSTC_VERSION = overrides.toolchain.channel;
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        # https://github.com/rust-lang/rust-bindgen#environment-variables
        shellHook = ''
          export PATH="''${CARGO_HOME:-~/.cargo}/bin":"$PATH"
          export PATH="$PWD/node_modules/.bin/:$PATH"
          export PATH="''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-${stdenv.hostPlatform.rust.rustcTarget}/bin":"$PATH"
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
            "/run/opengl-driver"
            "/run/opengl-driver-32"
            pkgs.libGL
            pkgs.libGLU
            pkgs.vulkan-loader
            pkgs.egl-wayland
            pkgs.wayland
            pkgs.libxkbcommon
            pkgs.xorg.libXcursor
          ]}:$LD_LIBRARY_PATH"
        '';
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

      }
  ) {}
