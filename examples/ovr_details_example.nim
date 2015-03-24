## *io-oculus* - Nim bindings for the Oculus VR SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import ovr, unsigned


template maskSet(value, mask: cuint): bool = (value and mask) != 0
  ## Helper template for testing bit masks.


# The following program is a basic example of using the `ovr` module to log details about one or
# more connected Oculus or GearVR devices to the console.

var
  displays: seq[OvrHmd] = @[] ## Holds the collection of detected HMDs


# initialize SDK
if ovrInitialize() == '\0':
  echo "Error: Failed to initialize Oculus SDK"
else:
  echo "Success: Initialized Oculus SDK version ", ovrGetVersionString()

  # detect available head-mounted displays
  let numDisplays = ovrHmdDetect()
  echo "Number of detected displays: ", numDisplays

  for i in 0..(numDisplays - 1):
    let d = ovrHmdCreate(i)
    if d == nil:
      echo "Warning: Failed to created handle for display #", i
    else:
      echo "Success: Created handle for display ", i, ":"
      displays.add(d)

  # print display details
  for i in 0..high(displays):
    echo "Details for display #", i
    let d: OvrHmd = displays[i]

    block:
      echo "  Description:"
      case d.hmdType
        of OvrHmdType.none: echo "    Type: None"
        of OvrHmdType.dK1: echo "    Type: DK1"
        of OvrHmdType.dKHD: echo "    Type: DK HD"
        of OvrHmdType.dK2: echo "    Type: DK2"
        of OvrHmdType.other: echo "    Type: Other"
      echo "    ProductName: ", d.productName
      echo "    Manufacturer: ", d.manufacturer
      echo "    VendorId: ", d.vendorId
      echo "    ProductId: ", d.productId
      echo "    SerialNumber: ", d.serialNumber
      echo "    Firmware: ", d.firmwareMajor, ".", d.firmwareMinor

    block:
      echo "  HMD Capabilities:"
      let caps = d.hmdCaps
      let enabledCaps = ovrHmdGetEnabledCaps(d)
      echo "    Present: ", maskSet(caps, ovrHmdCapPresent),
        "  (Enabled: ", maskSet(enabledCaps , ovrHmdCapPresent), ")"
      echo "    Available: ", maskSet(caps , ovrHmdCapAvailable),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapAvailable), ")"
      echo "    Captured: ", maskSet(caps , ovrHmdCapCaptured),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapCaptured), ")"
      echo "    ExtendDesktop: ", maskSet(caps , ovrHmdCapExtendDesktop),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapExtendDesktop), ")"
      echo "    DisplayOff: ", maskSet(caps , ovrHmdCapDisplayOff),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapDisplayOff), ")"
      echo "    LowPersistence: ", maskSet(caps , ovrHmdCapLowPersistence),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapLowPersistence), ")"
      echo "    DynamicPrediction: ", maskSet(caps , ovrHmdCapDynamicPrediction),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapDynamicPrediction), ")"
      echo "    DirectPentile: ", maskSet(caps , ovrHmdCapDirectPentile),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapDirectPentile), ")"
      echo "    NoVSync: ", maskSet(caps , ovrHmdCapNoVSync),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapNoVSync), ")"
      echo "    NoMirrorToWindow: ", maskSet(caps , ovrHmdCapNoMirrorToWindow),
        " (Enabled: ", maskSet(enabledCaps , ovrHmdCapNoMirrorToWindow), ")"

    block:
      echo "  Tracking Capabilities:"
      let caps = d.trackingCaps
      echo "    Orientation: ", maskSet(caps, ovrTrackingCapOrientation)
      echo "    MagYawCorrection: ", maskSet(caps, ovrTrackingCapMagYawCorrection)
      echo "    Position: ", maskSet(caps, ovrTrackingCapPosition)
      echo "    Idle: ", maskSet(caps, ovrTrackingCapIdle)

    block:
      echo "  Distortion Capabilities:"
      let caps = d.distortionCaps
      echo "    Chromatic: ", maskSet(caps, ovrDistortionCapChromatic)
      echo "    TimeWarp: ", maskSet(caps, ovrDistortionCapTimeWarp)
      echo "    Vignette: ", maskSet(caps, ovrDistortionCapVignette)
      echo "    NoRestore: ", maskSet(caps, ovrDistortionCapNoRestore)
      echo "    FlipInput: ", maskSet(caps, ovrDistortionCapFlipInput)
      echo "    SRGB: ", maskSet(caps, ovrDistortionCapSRGB)
      echo "    Overdrive: ", maskSet(caps, ovrDistortionCapOverdrive)
      echo "    HqDistortion: ", maskSet(caps, ovrDistortionCapHqDistortion)
      echo "    LinuxDevFullscreen: ", maskSet(caps, ovrDistortionCapLinuxDevFullscreen)
      echo "    ComputeShader: ", maskSet(caps, ovrDistortionCapComputeShader)
      echo "    ProfileNoTimewarpSpinWaits: ",
        maskSet(caps, ovrDistortionCapProfileNoTimewarpSpinWaits)

  # release detected displays
  for d in displays:
    ovrHmdDestroy(d)

  # shut down SDK
  ovrShutdown()

echo "Exiting."
