{ pkgs ? import <nixpkgs> { }
, kernelPackages ? pkgs.linuxPackages
}:

# Development shell for building this out-of-tree kernel module, following
# the recipe from the Nixpkgs manual:
#   https://nixos.org/manual/nixpkgs/stable/#sec-linux-kernel-developing-modules
#
# Usage:
#   nix-shell
#   make            # builds acer-wmi-ext.ko against $KDIR
#   make clean
#
# Target a different kernel (example: latest):
#   nix-shell --arg kernelPackages 'with import <nixpkgs> {}; linuxPackages_latest'
#
# To load the freshly built module:
#   sudo insmod ./acer-wmi-ext.ko
#   sudo dmesg -w
#   sudo rmmod acer_wmi_ext

let
  kernel = kernelPackages.kernel;
in
pkgs.mkShell {
  name = "acer-wmi-ext-dev";

  nativeBuildInputs = (kernel.moduleBuildDependencies or [ ]) ++ (with pkgs; [
    gnumake
    bc
    kmod
  ]);

  # Point the Makefile at the kernel build tree provided by Nix.
  KDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  shellHook = ''
    echo "acer-wmi-ext dev shell"
    echo "  kernel:  ${kernel.version} (modDir ${kernel.modDirVersion})"
    echo "  KDIR:    $KDIR"
    echo "  Build:   make"
    echo "  Clean:   make clean"
    if [ "${kernel.modDirVersion}" != "$(uname -r)" ]; then
      echo
      echo "  NOTE: running kernel is $(uname -r) but this shell targets"
      echo "        ${kernel.modDirVersion}. Built .ko cannot be insmod'd"
      echo "        into the live kernel unless versions match. Pick a"
      echo "        matching linuxPackages_X_Y via --argstr kernel, or just"
      echo "        use this shell to verify the module compiles."
    fi
  '';
}
