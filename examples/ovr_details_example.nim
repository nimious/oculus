#
#               io-oculus - Nim bindings for the Oculus VR SDK.
#                (c) Copyright 2015 Headcrash Industries LLC
#                   https://github.com/nimious/io-spacenav
#
# Oculus provides virtual reality head-mounted displays and positional tracking
# devices, such as the Rift, DK1, DK2 and GearVR. (http://www.oculus.com)
#
# This file is part of the `Nim I/O` package collection for the Nim programming
# language (http://nimio.us). See the file LICENSE included in this distribution
# for licensing details. Pull requests for fixes or improvements are encouraged.
#

import
  ovr,
  unsigned


template maskSet(value, mask: cuint): bool = (value and mask) != 0
  ## Helper template for testing bit masks.


# The following program is a basic example of using the `ovr` module to log
# details about one or more connected Oculus or GearVR devices to the console.

var
  displays: seq[ovrHmd] = @[]     ## Holds the collection of detected HMDs


# initialize SDK
if ovr_Initialize() == '\0':
  echo "Error: Failed to initialize Oculus SDK"
else:
  echo "Success: Initialized Oculus SDK version ", ovr_GetVersionString()

  # detect available head-mounted displays
  let numDisplays = ovrHmd_Detect()
  echo "Number of detected displays: ", numDisplays

  for i in 0..(numDisplays - 1):
    let d = ovrHmd_Create(i)
    if d == nil:
      echo "Warning: Failed to created handle for display #", i
    else:
      echo "Success: Created handle for display ", i, ":"
      displays.add(d)

  # print display details
  for i in 0..high(displays):
    echo "Details for display #", i
    let d: ovrHmd = displays[i]

    block:
      echo "  Description:"
      case d.Type
        of ovrHmd_None: echo "    Type: None"
        of ovrHmd_DK1: echo "    Type: DK1"
        of ovrHmd_DKHD: echo "    Type: DK HD"
        of ovrHmd_DK2: echo "    Type: DK2"
        of ovrHmd_Other: echo "    Type: Other"
      echo "    ProductName: ", d.ProductName
      echo "    Manufacturer: ", d.Manufacturer
      echo "    VendorId: ", d.VendorId
      echo "    ProductId: ", d.ProductId
      echo "    SerialNumber: ", d.SerialNumber
      echo "    Firmware: ", d.FirmwareMajor, ".", d.FirmwareMinor

    block:
      echo "  HMD Capabilities:"
      let caps = d.HmdCaps
      let enabledCaps = ovrHmd_GetEnabledCaps(d)
      echo "    Present: ", maskSet(caps, ovrHmdCap_Present), "  (Enabled: ", maskSet(enabledCaps , ovrHmdCap_Present), ")"
      echo "    Available: ", maskSet(caps , ovrHmdCap_Available), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_Available), ")"
      echo "    Captured: ", maskSet(caps , ovrHmdCap_Captured), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_Captured), ")"
      echo "    ExtendDesktop: ", maskSet(caps , ovrHmdCap_ExtendDesktop), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_ExtendDesktop), ")"
      echo "    DisplayOff: ", maskSet(caps , ovrHmdCap_DisplayOff), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_DisplayOff), ")"
      echo "    LowPersistence: ", maskSet(caps , ovrHmdCap_LowPersistence), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_LowPersistence), ")"
      echo "    DynamicPrediction: ", maskSet(caps , ovrHmdCap_DynamicPrediction), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_DynamicPrediction), ")"
      echo "    DirectPentile: ", maskSet(caps , ovrHmdCap_DirectPentile), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_DirectPentile), ")"
      echo "    NoVSync: ", maskSet(caps , ovrHmdCap_NoVSync), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_NoVSync), ")"
      echo "    NoMirrorToWindow: ", maskSet(caps , ovrHmdCap_NoMirrorToWindow), " (Enabled: ", maskSet(enabledCaps , ovrHmdCap_NoMirrorToWindow), ")"

    block:
      echo "  Tracking Capabilities:"
      let caps = d.TrackingCaps
      echo "    Orientation: ", maskSet(caps, ovrTrackingCap_Orientation)
      echo "    MagYawCorrection: ", maskSet(caps, ovrTrackingCap_MagYawCorrection)
      echo "    Position: ", maskSet(caps, ovrTrackingCap_Position)
      echo "    Idle: ", maskSet(caps, ovrTrackingCap_Idle)

    block:
      echo "  Distortion Capabilities:"
      let caps = d.DistortionCaps
      echo "    Chromatic: ", maskSet(caps, ovrDistortionCap_Chromatic)
      echo "    TimeWarp: ", maskSet(caps, ovrDistortionCap_TimeWarp)
      echo "    Vignette: ", maskSet(caps, ovrDistortionCap_Vignette)
      echo "    NoRestore: ", maskSet(caps, ovrDistortionCap_NoRestore)
      echo "    FlipInput: ", maskSet(caps, ovrDistortionCap_FlipInput)
      echo "    SRGB: ", maskSet(caps, ovrDistortionCap_SRGB)
      echo "    Overdrive: ", maskSet(caps, ovrDistortionCap_Overdrive)
      echo "    HqDistortion: ", maskSet(caps, ovrDistortionCap_HqDistortion)
      echo "    LinuxDevFullscreen: ", maskSet(caps, ovrDistortionCap_LinuxDevFullscreen)
      echo "    ComputeShader: ", maskSet(caps, ovrDistortionCap_ComputeShader)
      echo "    ProfileNoTimewarpSpinWaits: ", maskSet(caps, ovrDistortionCap_ProfileNoTimewarpSpinWaits)

  # release detected displays
  for d in displays:
    ovrHmd_Destroy(d)

  # shut down SDK
  ovr_Shutdown()

echo "Exiting."
