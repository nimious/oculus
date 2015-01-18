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

{.deadCodeElim: on.}


when defined(windows):
  when defined(win64):
    when defined(debug):
      const dllname = "libovr64d.dll"
    else:
      const dllname = "libovr64.dll"
  else:
    when defined(debug):
      const dllname = "libovrd.dll"
    else:
      const dllname = "libovr.dll"
elif defined(linux):
  const dllname = "libovr.so"
else:
  {.error: "Platform does not support libovr".}


include
  ovrcapi,
  ovrversion
