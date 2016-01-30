# *oculus* - Nim bindings for the Oculus VR SDK.
#
# This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
# See the file LICENSE included in this distribution for licensing details.
# GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.
#
# ------------
#
# This module declares constants used by the OVR API.

const
  OVR_KEY_USER* = "User" # string
  OVR_KEY_NAME* = "Name" # string
  OVR_KEY_GENDER* = "Gender" # string
  OVR_KEY_PLAYER_HEIGHT* = "PlayerHeight" # cfloat
  OVR_KEY_EYE_HEIGHT* = "EyeHeight" # cfloat
  OVR_KEY_IPD* = "IPD" # cfloat
  OVR_KEY_NECK_TO_EYE_DISTANCE* = "NeckEyeDistance" # cfloat[2]
  OVR_KEY_EYE_RELIEF_DIAL* = "EyeReliefDial" # cint
  OVR_KEY_EYE_TO_NOSE_DISTANCE* = "EyeToNoseDist" # cfloat[2]
  OVR_KEY_MAX_EYE_TO_PLATE_DISTANCE* = "MaxEyeToPlateDist" # cfloat[2]
  OVR_KEY_EYE_CUP* = "EyeCup" # cchar[16]
  OVR_KEY_CUSTOM_EYE_RENDER* = "CustomEyeRender" # bool
  OVR_KEY_CAMERA_POSITION* = "CenteredFromWorld" # cdouble[7]


  # Default measurements empirically determined at Oculus to make us happy. The neck model numbers
  # were derived as an average of the male and female averages from ANSUR-88:
  #
  #   `NECK_TO_EYE_HORIZONTAL = H22 - H43 = INFRAORBITALE_BACK_OF_HEAD - TRAGION_BACK_OF_HEAD`
  #   `NECK_TO_EYE_VERTICAL = H21 - H15 = GONION_TOP_OF_HEAD - ECTOORBITALE_TOP_OF_HEAD`
  #
  # These were determined to be the best in a small user study, clearly beating out the previous
  # default values

  OVR_DEFAULT_GENDER* = "Unknown"
  OVR_DEFAULT_PLAYER_HEIGHT* = 1.778f
  OVR_DEFAULT_EYE_HEIGHT* = 1.675f
  OVR_DEFAULT_IPD* = 0.064f
  OVR_DEFAULT_NECK_TO_EYE_HORIZONTAL* = 0.0805f
  OVR_DEFAULT_NECK_TO_EYE_VERTICAL = 0.075f
  OVR_DEFAULT_EYE_RELIEF_DIAL = 3
  OVR_DEFAULT_CAMERA_POSITION = {0,0,0,1,0,0,0}
