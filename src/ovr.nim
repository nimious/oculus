# *io-oculus* - Nim bindings for the Oculus VR SDK.
#
# This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
# See the file LICENSE included in this distribution for licensing details.
# GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

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
