# acer-wmi-ext

## Description

This repository contains an experimental Linux kernel driver for the
battery health control WMI interface and fan control modes of Acer laptops.
It can be used to control two battery-related features of Acer laptops that Acer
provides through the Acer Care Center/AcerSense on Windows: a health mode that
limits the battery charge to 80% with the goal of preserving your
battery's capacity and a battery calibration mode which puts your
battery through a controlled charge-discharge cycle to provide more
accurate battery capacity estimates.

On the Acer Swift Go 14 (SFG14-73), it can also set fan profiles
(Balanced, Quiet, Performance) based on the currently-set platform power
profile (used by power-profiles-daemon). Fan profiles are controlled
through the Acer ApgeAction WMI interface (GUID
`61EF69EA-865C-4BC3-A502-A0DEBA0CB531`, method `WMAA`, function `0x07`)
rather than by poking EC registers directly. The original EC offsets
provided by @YFHD-osu in [their repository](https://github.com/YFHD-osu/sfg14-fanmode)
were used by earlier versions of this driver.

## Building

Make sure that you have the kernel headers for your kernel installed
and type `make` in the cloned project directory. In more detail,
on a Debian or Ubuntu system, you can build by:
```
sudo apt install build-essential linux-headers-$(uname -r) git
git clone https://github.com/TenSeventy7/acer-wmi-ext.git
cd acer-wmi-ext
make
```

### NixOS

A `shell.nix` is provided that follows the
[Developing kernel modules](https://nixos.org/manual/nixpkgs/stable/#sec-linux-kernel-developing-modules)
recipe from the Nixpkgs manual. Enter the shell and build:
```
nix-shell
make
```
The shell sets `KDIR` to the build tree of the nixpkgs channel's
`linuxPackages.kernel`. To target a different kernel:
```
nix-shell --arg kernelPackages 'with import <nixpkgs> {}; linuxPackages_latest'
```
Note that `insmod` requires the built module's kernel version to match the
booted one (`uname -r`).

## Using

Loading the module without any parameters does not
change any health or calibration mode settings of your system:

```
sudo insmod acer-wmi-ext.ko
```

### Health mode

The charge limit can then be enabled as follows:
```
echo 1 | sudo tee /sys/bus/wmi/drivers/acer-wmi-ext/health_mode
```

Alternatively, you can enable it at module initialization
time:
```
sudo insmod acer-wmi-ext.ko enable_health_mode=1
```

### Calibration mode

Before attempting the battery calibration, connect
your laptop to a power supply. The calibration mode
can be started as follows:
```
echo 1 | sudo tee /sys/bus/wmi/drivers/acer-wmi-ext/calibration_mode
```


The calibration disables health mode and charges
to 100%. Then it discharges and recharges the battery
once. This can take a long time and for accurate
capacity estimates the laptop should not be used
during this process. After the discharge-charge cycle
the calibration mode should be manually disabled
since the WMI event that indicates the completion
of the calibration is not yet handled by the module:
```
echo 0 | sudo tee /sys/bus/wmi/drivers/acer-wmi-ext/calibration_mode
```

### Fan Profiles

The fan profiles can then be set as follows:
```
echo 0 | sudo tee /sys/bus/wmi/drivers/acer-wmi-ext/system_control_mode
```

The profile values are:

- `0`: Balanced
- `2`: Quiet
- `3`: Performance

These values come from the WMAA ApgeAction WMI method (function `0x07`)
and are defined by the Acer firmware, not the driver. They are hooked
into platform power profiles and can therefore also be controlled through
power-profiles-daemon and the desktop environment.

Alternatively, you can set it at module initialization time:
```
sudo insmod acer-wmi-ext.ko enable_system_control_mode=0
```

### Related work

Earlier versions of this driver set fan profiles by writing to an EC
register at a model-specific offset. The EC offsets for the SFG14-73 were
provided by @YFHD-osu in [their repository](https://github.com/YFHD-osu/sfg14-fanmode).
The driver has since been refactored to use the ApgeAction WMI method
directly, which is the same interface AcerSense uses on Windows and
removes the need for per-model EC offset quirks.

There exists [another driver](https://github.com/maxco2/acer-battery-wmi) with
similar functionality of which I have not been aware when starting the work
on this driver. See this [issue](https://github.com/frederik-h/acer-wmi-battery/issues/2) for discussion.
