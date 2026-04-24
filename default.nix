{ stdenv, lib, kernel, ... }:

stdenv.mkDerivation {
  pname = "acer-wmi-ext";
  version = "0.0.0";

  src = ./.;

  nativeBuildInputs = [ kernel.moduleBuildDependencies ];

  # The Makefile expects KDIR to point to the kernel build directory.
  makeFlags = [ "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];

  meta = with lib; {
    description = "Acer WMI extensions for fan control and battery charging";
    homepage = https://github.com/TenSeventy7/acer-wmi-ext;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}