{ stdenv, lib, kernel, ... }:

let
  isClang = kernel.stdenv.cc.isClang or false;
in
stdenv.mkDerivation {
  pname = "acer-wmi-ext";
  version = "0.0.0";

  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies ++ lib.optionals isClang [
    kernel.stdenv.cc.cc
    kernel.stdenv.cc.bintools.bintools
  ];

  # The Makefile expects KDIR to point to the kernel build directory.
  makeFlags = kernel.commonMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ] ++ lib.optional isClang "LLVM=1";

  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];

  meta = with lib; {
    description = "Acer WMI extensions for fan control and battery charging";
    homepage = https://github.com/TenSeventy7/acer-wmi-ext;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}