## *oculus* - Nim bindings for the Oculus VR SDK.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.
##
## ------------
##
## Basic steps to use the API
##
## Setup:
## 1. `ovrInitialize <#ovrInitialize>`_
##    `ovrHMD <#ovrHMD>`_ hmd = `ovrHmdCreate <#ovrHmdCreate>`_ (0)
## 2. Use `hmd` members and
##    `ovrHmdGetFovTextureSize <#ovrHmdGetFovTextureSize>`_ to determine
##    graphics configuration.
## 3. Call `ovrHmdConfigureTracking <#ovrHmdConfigureTracking>`_ to configure
##    and initialize tracking.
## 4. Call `ovrHmdConfigureRendering <#ovrHmdConfigureRendering>`_ to setup
##    graphics for SDK rendering, which is the preferred
##    approach. Please refer to "Client Distorton Rendering" below if you prefer
##    to do that instead.
## 5. If the `ovrHmdCapExtendDesktop <#ovrHmdCapExtendDesktop>`_ flag is not
##    set, then use `ovrHmdAttachToWindow <#ovrHmdAttachToWindow>`_ to associate
##    the relevant application window with the HMD.
## 6. Allocate render target textures as needed.
##
## Game Loop:
## * Call `ovrHmdBeginFrame <#ovrHmdBeginFrame>`_ to get the current frame
##   timing information.
## * Render each eye using `ovrHmdGetEyePoses <#ovrHmdGetEyePoses>`_ or
##   `ovrHmdGetHmdPosePerEye <#ovrHmdGetHmdPosePerEye>`_ to get the predicted
##   HMD pose and each eye pose.
## * Call `ovrHmdEndFrame <#ovrHmdEndFrame>`_ to render the distorted
##   textures to the back buffer and present them on the HMD.
##
## Shutdown:
## * `ovrHmdDestroy <#ovrHmdDestroy>`_ (hmd)
## * `ovrShutdown <#ovrShutdown>`_

# TODO gmp: add support for object field alignment

type
  OvrBool* = cchar


# Simple Math Structures #######################################################

type
  OvrVector2i* = object
    ## A 2D vector with integer components.
    x*: cint
    y*: cint

  OvrSizei* = object
    ## A 2D size with integer components.
    w*: cint
    h*: cint

  OvrRecti* = object
    ## A 2D rectangle with a position and size. All components are integers.
    Pos*: OvrVector2i
    Size*: OvrSizei

  OvrQuatf* = object
    ## A quaternion rotation.
    x*: cfloat
    y*: cfloat
    z*: cfloat
    w*: cfloat

  OvrVector2f = object
    ## A 2D vector with float components.
    x*: cfloat
    y*: cfloat

  OvrVector3f* = object
    ## A 3D vector with float components.
    x*: cfloat
    y*: cfloat
    z*: cfloat

  OvrMatrix4f* = object
    ## A 4x4 matrix with float elements.
    m*: array[4, array[4, cfloat]]

  OvrPosef* = object
    ## Position and orientation together.
    orientation*: OvrQuatf
    position*: OvrVector3f

  OvrPoseStatef* = object
    ## A full pose (rigid body) configuration with first and second derivatives.
    thePose*: OvrPosef
      ## The body's position and orientation.
    angularVelocity*: OvrVector3f
      ## The body's angular velocity in radians per second.
    linearVelocity*: OvrVector3f
      ## The body's velocity in meters per second.
    angularAcceleration*: OvrVector3f
      ## The body's angular acceleration in radians per second per second.
    linearAcceleration*: OvrVector3f
      ## The body's acceleration in meters per second per second.
    timeInSeconds*: cdouble
      ## Absolute time of this state sample.

  OvrFovPort* = object
    ## Field Of View (FOV) in tangent of the angle units. As an example, for a
    ## standard 90 degree vertical FOV, we would have:
    ##
    ##  { UpTan = tan(90 degrees / 2), DownTan = tan(90 degrees / 2) }
    upTan*: cfloat
      ## The tangent of the angle between the viewing vector and the top edge of
      ## the field of view.
    downTan*: cfloat
      ## The tangent of the angle between the viewing vector and the bottom edge
      ## of the field of view.
    leftTan*: cfloat
      ## The tangent of the angle between the viewing vector and the left edge
      ## of the field of view.
    rightTan*: cfloat
      ## The tangent of the angle between the viewing vector and the right edge
      ## of the field of view.


# HMD Types ####################################################################

type
  ## Enumerates all HMD types that we support.
  OvrHmdType* {.pure, size: sizeof(cint).} = enum
    none = 0,
      ## No device type.
    dK1 = 3,
      ## Oculus DevKit 1.
    dKHD = 4,
      ## Oculus DevKit HD.
    dK2 = 6,
      ## Oculus DevKit 2.
    other
      ## Unspecified device type.


# HMD Capability Bits ##########################################################

# Read-only flags.
const
  ovrHmdCapPresent*: cuint = 0x00000001
    ## The HMD is plugged in and detected by the system.
  ovrHmdCapAvailable*: cuint = 0x00000002
    ## The HMD and its sensor are available for ownership use, i.e. it is not
    ## already owned by another application.
  ovrHmdCapCaptured*: cuint = 0x00000004
    ## Set to 'true' if we capt ownership of this HMD.

  # These flags are intended for use with the new driver display mode.
  ovrHmdCapExtendDesktop*: cuint = 0x00000008
    ## (read only) Means the display driver is in compatibility mode.

  # Modifiable flags (through ovrHmdSetEnabledCaps).
  ovrHmdCapDisplayOff*: cuint = 0x00000040
    ## Turns off HMD screen and output (only if 'ExtendDesktop' is off).
  ovrHmdCapLowPersistence*: cuint = 0x00000080
    ## HMD supports low persistence mode.
  ovrHmdCapDynamicPrediction*: cuint = 0x00000200
    ## Adjust prediction dynamically based on internally measured latency.
  ovrHmdCapDirectPentile*: cuint = 0x00000400
    ## Write directly in pentile color mapping format
  ovrHmdCapNoVSync*: cuint = 0x00001000
    ## Support rendering without VSync for debugging.
  ovrHmdCapNoMirrorToWindow*: cuint = 0x00002000
    ## Disables mirroring of HMD output to the window. This may improve
    ## rendering performance slightly (only if 'ExtendDesktop' is off).
  ovrHmdCapService_Mask*: cuint = 0x000022F0
    ## These flags are currently passed into the service. May change without
    ## notice.
  ovrHmdCapWritable_Mask*: cuint = 0x000032F0
    ## These bits can be modified by
    ## `ovrHmdSetEnabledCaps <#ovrHmdSetEnabledCaps>`_.


# Tracking Capability Bits #####################################################

# Tracking capability bits reported by the device.
# Used with ovrHmdConfigureTracking.
const
  ovrTrackingCapOrientation*: cuint = 0x00000010 ## Supports orientation
    ## tracking (IMU).
  ovrTrackingCapMagYawCorrection*: cuint = 0x00000020 ## Supports yaw drift
    ## correction via a magnetometer or other means.
  ovrTrackingCapPosition*: cuint = 0x00000040 ## Supports positional tracking.
  ovrTrackingCapIdle*: cuint = 0x00000100 ## Overrides the other flags.
    ## Indicates that the application doesn't care about tracking settings.
    ## This is the internal default before
    ## `ovrHmdConfigureTracking <#ovrHmdConfigureTracking>` is called.


# Distortion Capability Bits ###################################################

# Used with ovrHmdConfigureRendering and ovrHmdCreateDistortionMesh.
const
  ovrDistortionCapChromatic*: cuint = 0x00000001
    ## Supports chromatic aberration correction
  ovrDistortionCapTimeWarp*: cuint = 0x00000002
    ## Supports timewarp
  ovrDistortionCapVignette*: cuint = 0x00000008
    ## Supports vignetting around the edges of the view
  ovrDistortionCapNoRestore*: cuint = 0x00000010
    ## Do not save and restore the graphics and compute state when rendering
    ## distortion
  ovrDistortionCapFlipInput*: cuint = 0x00000020
    ## Flip the vertical texture coordinate of input images
  ovrDistortionCapSRGB*: cuint = 0x00000040
    ## Assume input images are in sRGB gamma-corrected color space
  ovrDistortionCapOverdrive*: cuint = 0x00000080
    ## Overdrive brightness transitions to reduce artifacts on DK2+ displays
  ovrDistortionCapHqDistortion*: cuint = 0x00000100
    ## High-quality sampling of distortion buffer for anti-aliasing
  ovrDistortionCapLinuxDevFullscreen*: cuint = 0x00000200
    ## Indicates window is fullscreen on a device when set. The SDK will
    ## automatically apply distortion mesh rotation if needed
  ovrDistortionCapComputeShader*: cuint = 0x00000400
    ## Using compute shader (DX11+ only)
  ovrDistortionCapProfileNoTimewarpSpinWaits*: cuint = 0x00010000
    ## Use when profiling with timewarp to remove false positives


# Distortion Capability Bits ###################################################

type
  ## Specifies which eye is being used for rendering. This type explicitly does
  ## not include a third "NoStereo" option, as such is not required for an
  ## HMD-centered API.
  OvrEyeType* {.pure, size: sizeof(cint).} = enum
    left = 0,
    right = 1,
    count = 2


type
  OvrHmdStruct* = object
    ## Dummy object for internal HMD handles.


  OvrHmdDesc* = object
    ## This is a complete descriptor of the HMD.
    handle*: ptr OvrHmdStruct
      ## Internal handle of this HMD
    hmdType*: OvrHmdType
      ## This HMD's type
    productName*: cstring
      ## Name string describing the product
    manufacturer*: cstring
      ## Name string describing the manufacturer
    vendorId*: cshort
      ## HID Vendor of the device
    productId*: cshort
      ## ProductId of the device
    serialNumber*: array[24, char] ## Sensor (and display) serial number
    firmwareMajor*: cshort
      ## Sensor firmware version (major)
    firmwareMinor*: cshort
      ## Sensor firmware version (minor)
    cameraFrustumHFovInRadians*: cfloat
      ## External tracking camera frustum dimensions (if present)
    cameraFrustumVFovInRadians*: cfloat
      ## External tracking camera frustum
      ## dimensions (if present)
    cameraFrustumNearZInMeters*: cfloat
      ## External tracking camera frustum
      ## dimensions (if present)
    cameraFrustumFarZInMeters*: cfloat
      ## External tracking camera frustum dimensions (if present)
    hmdCaps*: cuint
      ## Capability bits described by ovrHmdCaps
    trackingCaps*: cuint
      ## Capability bits described by ovrTrackingCaps
    distortionCaps*: cuint
      ## Capability bits described by ovrDistortionCaps
    defaultEyeFov*: array[OvrEyeType.count, OvrFovPort]
      ## Recommended optical FOVs for the HMD
    maxEyeFov*: array[OvrEyeType.count, OvrFovPort]
      ## Maximum optical FOVs for the HMD
    eyeRenderOrder*: array[OvrEyeType.count, OvrEyeType]
      ## Preferred eye rendering order for best performance. Can help reduce
      ## latency on sideways-scanned screens
    resolution*: OvrSizei
      ## Resolution of the full HMD screen (both eyes) in pixels
    windowsPos*: OvrVector2i
      ## Location of the application window on the desktop (or 0,0)
    displayDeviceName*: cstring
      ## Display that the HMD should present on
    displayId*: cint
      ## Display identifier (Mac OSX only)

type
  OvrHmd* = ptr OvrHmdDesc
    ## Pointer to HMD descriptor objects.

type
  ## Bit flags describing the current status of sensor tracking.
  OvrStatusBits* {.pure, size: sizeof(cint).} = enum
    orientationTracked = 0x00000001,
      ## Orientation is currently tracked (in use)
    positionTracked = 0x00000002,
      ## Position is currently tracked (false if out of range)
    cameraPoseTracked = 0x00000004,
      ## Camera pose is currently tracked
    positionConnected = 0x00000020,
      ## Position tracking hardware is connected
    hmdConnected = 0x00000080
      ## HMD Display is available and connected

type
  OvrSensorData* = object
    ## Specifies a reading we can query from the sensor.
    accelerometer*: OvrVector3f ## Acceleration reading in m/s^2.
    gyro*: OvrVector3f ## Rotation rate in rad/s.
    magnetometer*: OvrVector3f ## Magnetic field in Gauss.
    temperature*: cfloat ## Temperature of the sensor in degrees Celsius.
    timeInSeconds*: cfloat ## Time when the reported IMU reading took place, in
      ## seconds.


  OvrTrackingState* = object
    ## Tracking state at a given absolute time (describes predicted HMD pose
    ## etc). Returned by `ovrHmdGetTrackingState <#ovrHmdGetTrackingState>`_.
    headPose*: OvrPoseStatef
      ## Predicted head pose (and derivatives) at the requested absolute time.
      ## The look-ahead interval is
      ## `(HeadPose.TimeInSeconds - RawSensorData.TimeInSeconds)`.
    cameraPose*: OvrPosef
      ## Current pose of the external camera (if present). This pose includes
      ## camera tilt (roll and pitch). For a leveled coordinate system use
      ## `LeveledCameraPose <#OvrTrackingState>`_.
    leveledCameraPose*: OvrPosef
      ## Camera frame aligned with gravity. This value includes position and yaw
      ## of the camera, but not roll and pitch. It can be used as a reference
      ## point to render real-world objects in the correct location.
    rawSensorData*: OvrSensorData
      ## The most recent sensor data received from the HMD.
    statusFlags*: cuint
      ## Tracking status described by `OvrStatusBits <#OvrStatusBits>`_.

    # 0.4.1
    lastVisionProcessingTime*: cdouble
      ## Measures the time from receiving the camera frame until vision CPU
      ## processing completes.

    # 0.4.3
    lastVisionFrameLatency*: cdouble
      ## Measures the time from exposure until the pose is available for the
      ## frame, including processing time.
    lastCameraFrameCounter*: cuint
      ## Tag the vision processing results to a certain frame counter number.


  OvrFrameTiming* = object
    ## Frame timing data reported by
    ## `ovrHmdBeginFrameTiming <#ovrHmdBeginFrameTiming>`_ or
    ## `ovrHmdBeginFrame <#ovrHmdBeginFrame>`_.
    deltaSeconds*: cfloat
      ## The amount of time that has passed since the previous frame's
      ## `ThisFrameSeconds <#OvrFrameTiming>`_ value (usable for movement
      ## scaling). This will be clamped to no more than 0.1 seconds to prevent
      ## excessive movement after pauses due to loading or initialization. It is
      ## generally expected that the following holds:
      ##     `ThisFrameSeconds < TimewarpPointSeconds < NextFrameSeconds <
      ##     EyeScanoutSeconds[EyeOrder[0]] <= ScanoutMidpointSeconds <=
      ##     EyeScanoutSeconds[EyeOrder[1]]`.
    thisFrameSeconds*: cdouble
      ## Absolute time value when rendering of this frame began or is expected
      ## to begin. Generally equal to `NextFrameSeconds` of the previous frame.
      ## Can be used for animation timing.
    timewarpPointSeconds*: cdouble
      ## Absolute point when IMU expects to be sampled for this frame.
    nextFrameSeconds*: cdouble
      ## Absolute time when frame Present followed by GPU Flush will finish and
      ## the next frame begins.
    scanoutMidpointSeconds*: cdouble
      ## Time when half of the screen will be scanned out. Can be passed as an
      ## absolute time to `ovrHmdGetTrackingState <#ovrHmdGetTrackingState>`_ to
      ## get the predicted general orientation.
    eyeScanoutSeconds*: array[2, cdouble]
      ## Timing points when each eye will be scanned out to display. Used when
      ## rendering each eye.


  OvrEyeRenderDesc* = object
    ## Rendering information for each eye. Computed by either
    ## `ovrHmdConfigureRendering <#ovrHmdConfigureRendering>`_ or
    ## `ovrHmdGetRenderDesc <#ovrHmdGetRenderDesc>`_ based on the specified FOV.
    ## Note that the rendering viewport is not included here as it can be
    ## specified separately and modified per frame through:
    ## - `ovrHmdGetRenderScaleAndOffset <#ovrHmdGetRenderScaleAndOffset>`_ in
    ##   the case of client rendered distortion, or
    ## - passing different values via `OvrTexture <#OvrTexture>`_ in the case of
    ##   SDK rendered distortion.
    eye*: OvrEyeType
      ## The eye index this instance corresponds to
    fov*: OvrFovPort
      ## The field of view
    distortedViewport*: OvrRecti
      ## Distortion viewport
    pixelsPerTanAngleAtCenter*: OvrVector2f
      ## How many display pixels will fit in `tan(angle) = 1`
    hmdToEyeViewOffset*: OvrVector3f
      ## Translation to be applied to view matrix for each eye offset


# Platform-independent Rendering Configuration #################################

# These types are used to hide platform-specific details when passing render
# device, OS, and texture data to the API. The benefit of having these wrappers
# versus platform-specific API functions is that they allow game glue code to be
# portable. A typical example is an engine that has multiple back ends, say GL
# and D3D. Portable code that calls these back ends may also use LibOVR. Back
# ends can be modified to return portable types such as
# `OvrTexture <#OvrTexture>`_ and `OvrRenderAPIConfig <#OvrRenderAPIConfig>`_.

type
  OvrRenderAPIType* {.pure, size: sizeof(cint).} = enum
    none,
    openGl,
    androidGles, # May include extra native window pointers, etc.
    d3d9,
    d3d10,
    d3d11,
    count


type #OVR_ALIGNAS(8)
  OvrRenderAPIConfigHeader* = object
    ## Platform-independent part of rendering API-configuration data. It is a
    ## part of `OvrRenderAPIConfig <#OvrRenderAPIConfig>`_, passed to
    ## `ovrHmdConfigureXXX`.
    api*: OvrRenderAPIType
    backBufferSize*: OvrSizei # Previously named RTSize
    multisample*: cint

type #OVR_ALIGNAS(8)
  OvrRenderAPIConfig* = object
    ## Contains platform-specific information for rendering.
    header*: OvrRenderAPIConfigHeader
    platformData*: array[8, ptr cuint]

type #OVR_ALIGNAS(8)
  OvrTextureHeader* = object
    ## Platform-independent part of the eye texture descriptor. It is a part of
    ## `OvrTexture <#OvrTexture>`_, passed to
    ## `ovrHmdEndFrame <#ovrHmdEndFrame>`_.
    ## If `RenderViewport <#OvrRenderAPIType>`_ is all zeros then the full
    ## texture will be used.
    api*: OvrRenderAPIType
    textureSize*: OvrSizei
    renderViewport*: OvrRecti # Pixel viewport in texture that holds eye image
    pad0*: cuint

type #OVR_ALIGNAS(8)
  OvrTexture* = object
    # Contains platform-specific information about a texture
    header*: OvrTextureHeader
    platformData*: array[8, ptr cuint]


# API Interfaces ###############################################################

proc ovrInitializeRenderingShim*(): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovr_InitializeRenderingShim".}
  ## Initialize the rendering shim appart from everything else in LibOVR.
  ##
  ## result
  ##   - ``true`` on success
  ##   - ``false`` on failure
  ##
  ## This may be helpful if the application prefers to avoid creating any OVR
  ## resources (allocations, service connections, etc) at this point. Does not
  ## bring up anything within LibOVR except the necessary hooks to enable the
  ## Direct-to-Rift functionality.
  ##
  ## Either `ovrInitializeRenderingShim <#ovrInitializeRenderingShim>`_ or
  ## `ovrInitialize <#ovrInitialize>`_ must be called before any Direct3D or
  ## OpenGL initilization is done by application (creating devices, etc).
  ## `ovrInitialize <#ovrInitialize>`_ must still be called after to use the
  ## rest of LibOVR APIs.


proc ovrInitialize*(): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovr_Initialize".}
  ## Initialize all Oculus functionality.
  ##
  ## result
  ##   - ``true`` on success
  ##   - ``false`` on failure
  ##
  ## Library init/shutdown, must be called around all other OVR code. No other
  ## functions calls besides
  ## `ovrInitializeRenderingShim <#ovrInitializeRenderingShim>`_ are allowed
  ## before `ovrInitialize <#ovrInitialize>`_ succeeds or after
  ## `ovrShutdown <#ovrShutdown>`_.


proc ovrShutdown*() {.cdecl, dynlib: dllname, importc: "ovr_Shutdown".}
  ## Shut down all Oculus functionality.


proc ovrGetVersionString*(): cstring
  {.cdecl, dynlib: dllname, importc: "ovr_GetVersionString".}
  ## Get the version of libOVR.
  ##
  ## result
  ##    - version string representing libOVR version
  ##
  ## The returned string is static and remains valid for app lifespan.


proc ovrHmdDetect*(): cint {.cdecl, dynlib: dllname, importc: "ovrHmd_Detect".}
  ## Detect or re-detects HMDs and reports the total number detected.
  ##
  ## result
  ##   - Number of connected head-mounted displays
  ##
  ## Users can get information about each HMD by calling
  ## `ovrHmdCreate <#ovrHmdCreate>`_ with an index.


proc ovrHmdCreate*(index: cint): OvrHmd
  {.cdecl, dynlib: dllname, importc: "ovrHmd_Create".}
  ## Create a handle to an HMD which doubles as a description structure.
  ##
  ## index
  ##   Index number of the HDM to create
  ## result
  ##   - `OvrHmd <#OvrHmd>`_ object on success
  ##   - ``nil`` on failure
  ##
  ## Index can be `[0..(ovrHmdDetect - 1)]`. Index mappings can cange after
  ## each `ovrHmdDetect <#ovrHmdDetect>`_ call. If not ``nil``, then the
  ## returned handle must be freed with `ovrHmdDestroy <#ovrHmdDestroy>`_.


proc ovrHmdDestroy*(hmd: OvrHmd)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_Destroy".}
  ## Destroy a handle to an HMD.
  ##
  ## hmd
  ##   Handle to a head-mounted display


proc ovrHmdCreateDebug*(`type`: OvrHmdType): OvrHmd
  {.cdecl, dynlib: dllname, importc: "ovrHmd_CreateDebug".}
  ## Create a fake HMD used for debugging only.
  ##
  ## type
  ##   The type of HMD to create.
  ## result
  ##   - HMD object on success
  ##   - ``nil`` on failure
  ##
  ## This is not tied to specific hardware, but may be used to debug some of the
  ## related rendering.


proc ovrHmdGetLastError*(hmd: OvrHmd): cstring
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetLastError".}
  ## Returns last error for HMD state.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## result
  ##   - error string
  ##   - ``nil`` for no error.
  ##
  ## String is valid until next call to
  ## `ovrHmdGetLastError <#ovrHmdGetLastError>`_ or HMD is destroyed. Pass
  ## ``nil`` hmd to get global errors (during create etc).


proc ovrHmdAttachToWindow*(hmd: OvrHmd; window: pointer;
  destMirrorRect: ptr OvrRecti; sourceRenderTargetRect: ptr OvrRecti): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_AttachToWindow".}
  ## Platform specific function to specify the application window whose output
  ## will be displayed on the HMD.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## window
  ##   The window to attach to
  ## destMirrorRect
  ##   (see below)
  ## sourceRenderTargetRect
  ##   (see below)
  ## result
  ##   - ``true`` on success
  ##   - ``false`` otherwise
  ##
  ## Only used if the `ovrHmdCapExtendDesktop <#ovrHmdCapExtendDesktop>`_ flag
  ## is ``false``.
  ##
  ## Windows: SwapChain associated with this window will be displayed on the
  ## HMD. Specify `destMirrorRect` in window coordinates to indicate an area
  ## of the render target output that will be mirrored from
  ## `sourceRenderTargetRect`. ``nil`` pointers mean "full size".
  ##
  ## Note: Source and dest mirror rects are not yet implemented.


proc ovrHmdGetEnabledCaps*(hmd: OvrHmd): cuint
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetEnabledCaps".}
  ## Gets the capability bits that are enabled at this time as described by
  ## `ovrHmdCapXXX` flags.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## result
  ##   Bit mask of enabled capabilities
  ##
  ## Note that this value is different font
  ## `OvrHmdDesc.HmdCaps <#OvrHmdDesc>`_, which describes what capabilities are
  ## available for that HMD.


proc ovrHmdSetEnabledCaps*(hmd: OvrHmd; hmdCaps: cuint)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_SetEnabledCaps".}
  ## Modifies capability bits described by ovrHmdCapXXX that can be modified.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## hmdCaps
  ##   Bit mask of capabilities to enable


# Tracking Interface ###########################################################

# All tracking interface functions are thread-safe, allowing tracking state to
# be sampled from different threads.

proc ovrHmdConfigureTracking*(hmd: OvrHmd; supportedTrackingCaps: cuint;
  requiredTrackingCaps: cuint): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_ConfigureTracking".}
  ## ConfigureTracking starts sensor sampling, enabling specified capabilities,
  ## described by ovrTrackingCaps.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## supportedTrackingCaps
  ##   (see below)
  ## result
  ##   - ``true`` on success
  ##   - ``false`` on failure
  ##
  ## `supportedTrackingCaps` specifies support that is requested. The function
  ## will succeed even if these caps are not available (i.e. sensor or camera is
  ## unplugged). Support will automatically be enabled if such device is plugged
  ## in later. Software should check
  ## `OvrTrackingState.StatusFlags <#OvrTrackingState>` for real-time status.
  ##
  ## `requiredTrackingCaps` specify sensor capabilities required at the time of
  ## the call. If they are not available, the function will fail. Pass ``0`` if
  ## only specifying `supportedTrackingCaps`.
  ##
  ## Pass ``0`` for both `supportedTrackingCaps` and `requiredTrackingCaps` to
  ## disable tracking.


proc ovrHmdRecenterPose*(hmd: OvrHmd)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_RecenterPose".}
  ## Re-centers the sensor orientation.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ##
  ## Normally this will recenter the `(x,y,z)` translational components and the
  ## yaw component of orientation.


proc ovrHmdGetTrackingState*(hmd: OvrHmd; absTime: cdouble): OvrTrackingState
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetTrackingState".}
  ## Returns tracking state reading based on the specified absolute system time.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## absTime
  ##  (see below)
  ##
  ## Pass an absTime value of 0.0 to request the most recent sensor reading. In
  ## this case both `PredictedPose` and `SamplePose` will have the same value.
  ## `ovrHmdGetEyePoses <#ovrHmdGetEyePoses>`_ relies on this function
  ## internally. This may also be used for more refined timing of FrontBuffer
  ## rendering logic, etc.


# Graphics Setup ###############################################################

proc ovrHmdGetFovTextureSize*(hmd: OvrHmd; eye: OvrEyeType; fov: OvrFovPort;
  pixelsPerDisplayPixel: cfloat): OvrSizei
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetFovTextureSize".}
  ## Calculates the recommended texture size for rendering a given eye within
  ## the HMD with a given FOV cone.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## eye
  ##   ?
  ## fov
  ##   ?
  ## pixelsPerDisplayPixel
  ##   Specifies the ratio of the number of render target pixels to display
  ##   pixels at the center of distortion. 1.0 is the default value. Lower
  ##   values can improve performance
  ## result
  ##   Texture size
  ##
  ## Higher FOV will generally require larger textures to maintain quality.


# Rendering API Thread Safety ##################################################

# All of rendering functions including the configure and frame functions are
# *NOT thread safe*. It is ok to use ConfigureRendering on one thread and handle
# frames on another thread, but explicit synchronization must be done since
# functions that depend on configured state are not reentrant.
#
# As an extra requirement, any of the following calls must be done on the render
# thread, which is the same thread that calls ovrHmdBeginFrame or
# ovrHmdBeginFrameTiming.
#    - ovrHmdEndFrame
#    - ovrHmdGetEyeTimewarpMatrices


# SDK Distortion Rendering Functions ###########################################

# These functions support rendering of distortion by the SDK through direct
# access to the underlying rendering API, such as D3D or GL. This is the
# recommended approach since it allows better support for future Oculus
# hardware, and enables a range of low-level optimizations.

proc ovrHmdConfigureRendering*(hmd: OvrHmd; apiConfig: ptr OvrRenderAPIConfig;
  distortionCaps: cuint; eyeFovIn: array[2, OvrFovPort];
  eyeRenderDescOut: array[2, OvrEyeRenderDesc]): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_ConfigureRendering".}
  ## Configures rendering and fills in computed render parameters.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## apiConfig
  ##   Provides D3D/OpenGL specific parameters. Pass ``nil`` to shut down
  ##   rendering and release all resources
  ## distortionCaps
  ##   Desired distortion settings
  ## eyeFovIn
  ##   ?
  ## eyeRenderDescOut
  ##   Pointer to an array of two `OvrEyeRenderDesc <#OvrEyeRenderDesc>`_
  ##   structs that are used to return complete rendering information for each
  ##   eye
  ## result
  ##   - ``true`` on success
  ##   - ``false`` otherwise
  ##
  ## This function can be called multiple times to change rendering settings.


proc ovrHmdBeginFrame*(hmd: OvrHmd; frameIndex: cuint): OvrFrameTiming
  {.cdecl, dynlib: dllname, importc: "ovrHmd_BeginFrame".}
  ## Begins a frame, returning timing information.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## frameIndex
  ##   ?
  ##
  ## This should be called at the beginning of the game rendering loop (on the
  ## render thread). Pass 0 for the frame index if not using
  ## `ovrHmdGetFrameTiming <#ovrHmdGetFrameTiming>`_.


proc ovrHmdEndFrame*(hmd: OvrHmd; renderPose: array[2, OvrPosef];
  eyeTexture: array[2, OvrTexture])
  {.cdecl, dynlib: dllname, importc: "ovrHmd_EndFrame".}
  ## Ends a frame, submitting the rendered textures to the frame buffer.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## renderPose
  ##   (see below)
  ## eyeTexture
  ##
  ## - RenderViewport within each `eyeTexture` can change per frame if
  ##   necessary.
  ## - `renderPose` will typically be the value returned from
  ##   `ovrHmdGetEyePoses <#ovrHmdGetEyePoses>`_ or
  ##   `ovrHmdGetHmdPosePerEye <#ovrHmdGetHmdPosePerEye>`_ but can be different
  ##   if a different head pose was used for rendering.
  ## - This may perform distortion and scaling internally, assuming is it not
  ##   delegated to another thread.
  ## - Must be called on the same thread as
  ##   `ovrHmdBeginFrame <#ovrHmdBeginFrame>`_.
  ##
  ## This cunction will call Present/SwapBuffers and potentially wait for GPU
  ## Sync.


proc ovrHmdGetEyePoses*(hmd: OvrHmd; frameIndex: cuint;
  hmdToEyeViewOffset: array[2, OvrVector3f]; outEyePoses: array[2, OvrPosef];
  outHmdTrackingState: ptr OvrTrackingState)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetEyePoses".}
  ##
  ## Returns predicted head pose in `outHmdTrackingState` and offset eye poses
  ## in outEyePoses as an atomic operation.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## frameIndex
  ##   (see below)
  ## hmdToEyeViewOffset
  ##   (see below)
  ## outEyePoses
  ##   (see below)
  ## outHmdTrackingState
  ##   (see below)
  ##
  ## Caller need not worry about applying `hmdToEyeViewOffset` to the returned
  ## outEyePoses variables.
  ##
  ## - Thread-safe function where caller should increment `frameIndex` with
  ##   every frame and pass the index where applicable to functions called on
  ##   the rendering thread.
  ## - `hmdToEyeViewOffset[2]` can be
  ##   `OvrEyeRenderDesc.HmdToEyeViewOffset <#OvrEyeRenderDesc>`_
  ##   returned from `ovrHmdConfigureRendering <#ovrHmdConfigureRendering>`_ or
  ##   `ovrHmdGetRenderDesc <#ovrHmdGetRenderDesc>`_. For monoscopic rendering,
  ##   use a vector that is the average of the two vectors for both eyes.
  ## - If `frameIndex` is not being used, pass in 0.
  ## - Assuming `outEyePoses` are used for rendering, it should be passed into
  ##   `ovrHmdEndFrame <#ovrHmdEndFrame>`_.
  ## - If called doesn't need `outHmdTrackingState`, it can be ``nil``


proc ovrHmdGetHmdPosePerEye*(hmd: OvrHmd; eye: OvrEyeType): OvrPosef
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetHmdPosePerEye".}
  ## Function was previously called ovrHmdGetEyePose
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## eye
  ##   (see below)
  ## result
  ##   The predicted head pose to use when rendering the specified eye
  ##
  ## - Important: Caller must apply HmdToEyeViewOffset before using
  ##   `OvrPosef <#OvrPosef>`_ for rendering
  ## - Must be called between
  ##   `ovrHmdBeginFrameTiming <#ovrHmdBeginFrameTiming>`_ and
  ##   `ovrHmdEndFrameTiming <#ovrHmdEndFrameTiming>`_
  ## - If the pose is used for rendering the eye, it should be passed to
  ##   `ovrHmdEndFrame <#ovrHmdEndFrame>`_.
  ## - Parameter `eye` is used for prediction timing only


# Client Distortion Rendering Functions ########################################

# These functions provide the distortion data and render timing support
# necessary to allow client rendering of distortion. Client-side rendering
# involves the following steps:
#
# 1. Setup ovrEyeDesc based on the desired texture size and FOV.
#    Call ovrHmdGetRenderDesc to get the necessary rendering parameters for
#    each eye.
#
# 2. Use ovrHmdCreateDistortionMesh to generate the distortion mesh.
#
# 3. Use ovrHmdBeginFrameTiming, ovrHmdGetEyePoses, and
#    ovrHmdBeginFrameTiming in the rendering loop to obtain timing and
#    predicted head orientation when rendering each eye.
#
# When using timewarp, use ovrWaitTillTime after the rendering and gpu flush,
# followed by ovrHmdGetEyeTimewarpMatrices to obtain the timewarp matrices used
# by the distortion pixel shader. This will minimize latency.

proc ovrHmdGetRenderDesc*(hmd: OvrHmd; eyeType: OvrEyeType; fov: OvrFovPort):
  OvrEyeRenderDesc {.cdecl, dynlib: dllname, importc: "ovrHmd_GetRenderDesc".}
  ## Compute the distortion viewport, view adjust, and other rendering
  ## parameters for the specified eye.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## eyeType
  ##   ?
  ## fov
  ##   ?
  ## result
  ##   ?
  ##
  ## This can be used instead of
  ## `ovrHmdConfigureRendering <#ovrHmdConfigureRendering>`_ to do setup for
  ## client rendered distortion.


type
  OvrDistortionVertex* = object
    ## Describes a vertex used by the distortion mesh. This is intended to be
    ## converted into the engine-specific format. Some fields may be unused
    ## based on the ovrDistortionCaps flags selected. TexG and TexB, for
    ## example, are not used if chromatic correction is not requested.
    screenPosNDC*: OvrVector2f
      ## [-1,+1],[-1,+1] over the entire framebuffer.
    timeWarpFactor*: cfloat
      ## Lerp factor between time-warp matrices. Can be encoded in Pos.z.
    vignetteFactor*: cfloat
      ## Vignette fade factor. Can be encoded in Pos.w.
    tanEyeAnglesR*: OvrVector2f
      ## The tangents of the horizontal and vertical eye angles for the red
      ## channel.
    tanEyeAnglesG*: OvrVector2f
      ## The tangents of the horizontal and vertical eye angles for the green
      ## channel.
    tanEyeAnglesB*: OvrVector2f
      ## The tangents of the horizontal and vertical eye angles for the blue
      ## channel.

  OvrDistortionMesh* = object
    ## Describes a full set of distortion mesh data, filled in by
    ## `ovrHmdCreateDistortionMesh <#ovrHmdCreateDistortionMesh>`_. Contents of
    ## this data structure, if not nil, should be freed by
    ## `ovrHmdDestroyDistortionMesh <#ovrHmdDestroyDistortionMesh>`_.
    pVertexData*: ptr OvrDistortionVertex
      ## The distortion vertices representing each point in the mesh.
    pIndexData*: ptr cushort
      ## Indices for connecting the mesh vertices into polygons.
    vertexCount*: cuint
      ## The number of vertices in the mesh.
    indexCount*: cuint
      ## The number of indices in the mesh.


proc ovrHmdCreateDistortionMesh*(hmd: OvrHmd; eyeType: OvrEyeType;
  fov: OvrFovPort; distortionCaps: cuint; meshData: ptr OvrDistortionMesh):
  OvrBool {.cdecl, dynlib: dllname, importc: "ovrHmd_CreateDistortionMesh".}
  ## Generate distortion mesh per eye.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## eyeType
  ##   ?
  ## fov
  ##   ?
  ## distortionCaps
  ##   (see below)
  ## meshData
  ##   Will hold the created distortion mesh data
  ## result
  ##   - ``true`` on success
  ##   - ``false`` otherwise
  ##
  ## Distortion capabilities will depend on `distortionCaps` flags. Users
  ## should render using the appropriate shaders based on their settings.
  ## Distortion mesh data will be allocated and written into the
  ## `OvrDistortionMesh <#OvrDistortionMesh>`_ data structure, which should be
  ## explicitly freed with
  ## `ovrHmdDestroyDistortionMesh <#ovrHmdDestroyDistortionMesh>`_.
  ##
  ## Users should call
  ## `ovrHmdGetRenderScaleAndOffset <#ovrHmdGetRenderScaleAndOffset>`_ to get
  ## uvScale and Offset values for rendering. The function shouldn't fail unless
  ## theres is a configuration or memory error, in which case the `meshData`
  ## values will be set to null. This is the only function in the SDK reliant on
  ## eye relief, currently imported from profiles, or overridden here.


proc ovrHmdCreateDistortionMeshDebug*(hmd: OvrHmd; eyeType: OvrEyeType;
  fov: OvrFovPort; distortionCaps: cuint; meshData: ptr OvrDistortionMesh;
  debugEyeReliefOverrideInMetres: cfloat): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_CreateDistortionMeshDebug".}
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## eyeType
  ##   ?
  ## fov
  ##   ?
  ## debugEyeReliefOverrideInMetres
  ##   ?
  ## result
  ##   - ``true`` on success
  ##   - ``false`` otherwise


proc ovrHmdDestroyDistortionMesh*(meshData: ptr OvrDistortionMesh)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_DestroyDistortionMesh".}
  ## Used to free the distortion mesh allocated by
  ## `ovrHmdCreateDistortionMesh <#ovrHmdCreateDistortionMesh>`_.
  ##
  ## meshData
  ##   Pointer to the mesh to destroy
  ##
  ## The `meshData` elements are set to nil and zeroes after the call.


proc ovrHmdGetRenderScaleAndOffset*(fov: OvrFovPort; textureSize: OvrSizei;
  renderViewport: OvrRecti; uvScaleOffsetOut: array[2, OvrVector2f])
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetRenderScaleAndOffset".}
  ## Computes updated 'uvScaleOffsetOut' to be used with a distortion if render
  ## target size or viewport changes after the fact. This can be used to adjust
  ## render size every frame if desired.


proc ovrHmdGetFrameTiming*(hmd: OvrHmd; frameIndex: cuint): OvrFrameTiming
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetFrameTiming".}
  ## Thread-safe timing function for the main thread.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## frameIndex
  ##   ?
  ## result
  ##   ?
  ##
  ## Caller should increment frameIndex with every frame and pass the index
  ## where applicable to functions called on the rendering thread.


proc ovrHmdBeginFrameTiming*(hmd: OvrHmd; frameIndex: cuint): OvrFrameTiming
  {.cdecl, dynlib: dllname, importc: "ovrHmd_BeginFrameTiming".}
  ## Called at the beginning of the frame on the rendering thread.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## frameIndex
  ##   ?
  ## result
  ##   ?
  ##
  ## Pass `frameIndex == 0` if `ovrHmdGetFrameTiming <#ovrHmdGetFrameTiming>`_
  ## isn't being used. Otherwise, pass the same frame index as was used for
  ## `ovrHmdGetFrameTiming <#ovrHmdGetFrameTiming>`_ on the main thread.


proc ovrHmdEndFrameTiming*(hmd: OvrHmd)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_EndFrameTiming".}
  ## Mark the end of client distortion rendered frame, tracking the necessary
  ## timing information.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ##
  ## This function must be called immediately after Present/SwapBuffers + GPU
  ## sync. GPU sync is important before this call to reduce latency and ensure
  ## proper timing.


proc ovrHmdResetFrameTiming*(hmd: OvrHmd; frameIndex: cuint)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_ResetFrameTiming".}
  ## Initialize and reset frame time tracking.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## frameIndex
  ##   ?
  ##
  ## This is typically not necessary, but is helpful if game changes vsync state
  ## or video mode. vsync is assumed to be on if this isn't called. Resets
  ## internal frame index to the specified number.


proc ovrHmdGetEyeTimewarpMatrices*(hmd: OvrHmd; eye: OvrEyeType;
  renderPose: OvrPosef; twmOut: array[2, OvrMatrix4f])
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetEyeTimewarpMatrices".}
  ## Compute timewarp matrices used by distortion mesh shader, these are used
  ## to adjust for head orientation change since the last call to
  ## ovrHmdGetEyePoses when rendering this eye.
  ##
  ## The `OvrDistortionVertex.timeWarpFactor <#OvrDistortionVertex>`_ is used to
  ## blend between the matrices, usually representing two different sides of the
  ## screen. Must be called on the same thread as ovrHmdBeginFrameTiming.


proc ovrHmdGetEyeTimewarpMatricesDebug*(hmd: OvrHmd; eye: OvrEyeType;
  renderPose: OvrPosef; twmOut: array[2, OvrMatrix4f];
  debugTimingOffsetInSeconds: cdouble)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetEyeTimewarpMatricesDebug".}


# Stateless math setup functions ###############################################

proc ovrMatrix4fProjection*(fov: OvrFovPort; znear: cfloat; zfar: cfloat;
  rightHanded: OvrBool): OvrMatrix4f
  {.cdecl, dynlib: dllname, importc: "ovr_Matrix4f_Projection".}
  ## Used to generate projection from `OvrEyeDesc.fov <#ovrEyeDesc>`_.
  ##
  ## fov
  ##   ?
  ## znear
  ##   ?
  ## zfar
  ##   ?
  ## rightHanded
  ##   ?
  ## result
  ##   ?


proc ovrMatrix4fOrthoSubProjection*(projection: OvrMatrix4f;
  orthoScale: OvrVector2f; orthoDistance: cfloat; hmdToEyeViewOffsetX: cfloat):
  OvrMatrix4f
  {.cdecl, dynlib: dllname, importc: "ovr_Matrix4f_OrthoSubProjection".}
  ## Used for 2D rendering, Y is down.
  ##
  ## project
  ##   ?
  ## orthoScale
  ##   `1.0f / pixelsPerTanAngleAtCenter`
  ## orthoDistance
  ##   Distance from camera, such as 0.8m
  ## hmdToEyeViewOFfsetX
  ##
  ## result
  ##   ?


proc ovrGetTimeInSeconds*(): cdouble
  {.cdecl, dynlib: dllname, importc: "ovr_GetTimeInSeconds".}
  ## Returns global, absolute high-resolution time in seconds.
  ##
  ## result
  ##   Resolution time
  ##
  ## This is the same value as used in sensor messages.


proc ovrWaitTillTime*(absTime: cdouble): cdouble
  {.cdecl, dynlib: dllname, importc: "ovr_WaitTillTime".}
  ## Waits until the specified absolute time.


# Latency Test interface #######################################################

proc ovrHmdProcessLatencyTest*(hmd: OvrHmd; rgbColorOut: array[3, cuchar]):
  OvrBool {.cdecl, dynlib: dllname, importc: "ovrHmd_ProcessLatencyTest".}
  ## Does latency test processing and returns ``true`` if specified RGB color
  ## should be used to clear the screen.


proc ovrHmdGetLatencyTestResult*(hmd: OvrHmd): cstring
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetLatencyTestResult".}
  ## Returns non-null string once with latency test result, when it is
  ## available. Buffer is valid until next call.


proc ovrHmdGetLatencyTest2DrawColor*(hmddesc: OvrHmd;
  rgbColorOut: array[3, cuchar]): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetLatencyTest2DrawColor".}
  ## result
  ##   - the latency testing color in rgbColorOut to render when using a DK2
  ##   - ``false`` if this feature is disabled or not-applicable (e.g. DK1)


# Health and Safety Warning Display interface ##################################

type
  ovrHSWDisplayState* = object
    ## Used by ovrhmd_GetHSWDisplayState to report the current display state.
    displayed*: OvrBool
      ## If true then the warning should be currently visible and the following
      ## variables have meaning. Else there is no warning being displayed for
      ## this application on the given HMD. ``true`` if the Health & Safety
      ## Warning is currently displayed.
    startTime*: cdouble
      ## Absolute time when the warning was first displayed.
      ## See `ovrGetTimeInSeconds <#ovrGetTimeInSeconds>`_
    dismissibleTime*: cdouble
      ## Earliest absolute time when the warning can be dismissed. May be a time
      ## in the past.


proc ovrHmdGetHSWDisplayState*(hmd: OvrHmd; hasWarningState:
  ptr ovrHSWDisplayState)
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetHSWDisplayState".}
  ## Gets the current state of the HSW display.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## hasWarningState
  ##   Will hold the display state
  ##
  ## If the application is doing the rendering of the HSW display then this
  ## function serves to indicate that the warning should be currently displayed.
  ## If the application is using SDK-based eye rendering then the SDK by default
  ## automatically handles the drawing of the HSW display.
  ##
  ## An application that uses application-based eye rendering should use this
  ## function to know when to start drawing the HSW display itself and can
  ## optionally use it in conjunction with
  ## `ovrHmdDismissHSWDisplay <#ovrHmdDismissHSWDisplay>`_ as described below.
  ## Example usage for application-based rendering:
  ##
  ## .. code-block:: nim
  ##   var hswDisplayCurrentlyDisplayed = false ## global or class member var
  ##   var hswDisplayState: ovrHSWDisplayState
  ##   ovrhmdGetHSWDisplayState(hmd, addr(hswDisplayState))
  ##
  ##   if hswDisplayState.Displayed && !HSWDisplayCurrentlyDisplayed
  ##     # insert model into the scene that stays in front of the user
  ##     hswWDisplayCurrentlyDisplayed = true


proc ovrHmdDismissHSWDisplay*(hmd: OvrHmd): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_DismissHSWDisplay".}
  ## Dismisses the HSW display if the warning is dismissible and the earliest
  ## dismissal time has occurred.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## result
  ##   - ``true`` if the display is valid and could be dismissed
  ##   - ``false`` otherwise
  ##
  ## The application should recognize that the HSW display is being displayed
  ## (via `ovrHmdGetHSWDisplayState <#ovrHmdGetHSWDisplayState>`_) and if so
  ## then call this function when the appropriate user input to dismiss the
  ## warning occurs. Example usage:
  ##
  ## .. code-block:: nim
  ##   proc processEvent(int key)
  ##     if key == escape
  ##       var hswDisplayState: ovrHSWDisplayState
  ##       ovrhmdGetHSWDisplayState(hmd, addr(hswDisplayState));
  ##
  ##       if hswDisplayState.Displayed && ovrhmd_DismissHSWDisplay(hmd)
  ##         <remove model from the scene>
  ##         hswDisplayCurrentlyDisplayed = false


proc ovrHmdGetBool*(hmd: OvrHmd; propertyName: cstring; defaultVal: OvrBool):
  OvrBool {.cdecl, dynlib: dllname, importc: "ovrHmd_GetBool".}
  ## Get a boolean property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to get
  ## defaultVal
  ##   Default value to return if property doesn't exist
  ## result
  ##   - first element if property is a boolean array
  ##   - `defaultValue` if property doesn't exist


proc ovrHmdSetBool*(hmd: OvrHmd; propertyName: cstring; value: OvrBool): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_SetBool".}
  ## Modify a bool property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to set
  ## value
  ##   The value to set
  ## result
  ##   - ``true`` on success
  ##   - ``false`` if property doesn't exist or is readonly


proc ovrHmdGetInt*(hmd: OvrHmd; propertyName: cstring; defaultVal: cint): cint
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetInt".}
  ## Get an integer property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to get
  ## defaultVal
  ##   Default value to return if property doesn't exist
  ## result
  ##   - first element if property is an integer array
  ##   - `defaultValue` if property doesn't exist


proc ovrHmdSetInt*(hmd: OvrHmd; propertyName: cstring; value: cint): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_SetInt".}
  ## Modify an integer property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to set
  ## value
  ##   The value to set
  ## result
  ##   - ``true`` on success
  ##   - ``false`` if property doesn't exist or is readonly


proc ovrHmdGetFloat*(hmd: OvrHmd; propertyName: cstring; defaultVal: cfloat):
  cfloat {.cdecl, dynlib: dllname, importc: "ovrHmd_GetFloat".}
  ## Get a float property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to get
  ## defaultVal
  ##   Default value to return if property doesn't exist
  ## result
  ##   - first element if property is a float array
  ##   - `defaultValue` if property doesn't exist


proc ovrHmdSetFloat*(hmd: OvrHmd; propertyName: cstring; value: cfloat):
  OvrBool {.cdecl, dynlib: dllname, importc: "ovrHmd_SetFloat".}
  ## Modify a `float` property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to set
  ## value
  ##   The value to set
  ## result
  ##   - ``true`` on success
  ##   - ``false`` if property doesn't exist or is readonly


proc ovrHmdGetFloatArray*(hmd: OvrHmd; propertyName: cstring;
  values: ptr cfloat; arraySize: cuint): cuint
  {.cdecl, dynlib: dllname, importc: "ovrHmd_GetFloatArray".}
  ## Get a `float[]` property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to get
  ## values
  ##   Will hold the array values.
  ## result
  ##   - Number of elements filled in
  ##   - ``0`` if property doesn't exist
  ##
  ## A maximum of `arraySize` elements will be written.


proc ovrHmdSetFloatArray*(hmd: OvrHmd; propertyName: cstring;
  values: ptr cfloat; arraySize: cuint): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_SetFloatArray".}
  ## Modify a `float[]` property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   The name of the property to set
  ## values
  ##   The values to set
  ## result
  ##   - ``true`` on success
  ##   - ``false`` if property doesn't exist or is readonly


proc ovrHmdGetString*(hmd: OvrHmd; propertyName: cstring; defaultVal: cstring):
  cstring {.cdecl, dynlib: dllname, importc: "ovrHmd_GetString".}
  ## Get string property.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## propertyName
  ##   defaultVal
  ## result
  ##   - The first element if property is a string array
  ##   - `defaultValue` if property doesn't exist
  ##
  ## String memory is guaranteed to exist until next call to
  ## `ovrHmdGetString <#ovrHmdGetString>`_ or
  ## `ovrHmdGetStringArray <#ovrHmdGetStringArray>`_, or HMD is destroyed.


proc ovrHmdSetString*(hmddesc: OvrHmd; propertyName: cstring; value: cstring):
  OvrBool {.cdecl, dynlib: dllname, importc: "ovrHmd_SetString".}
  ## Set string property


# Logging ######################################################################

proc ovrHmdStartPerfLog*(hmd: OvrHmd; fileName: cstring;
  userData1: cstring): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_StartPerfLog".}
  ## Start performance logging.
  ##
  ## hmd
  ##   Handle to a head-mounted display
  ## fileName
  ##   The name of the output file
  ## userData1
  ##   Optional string to be written with each file entry
  ## result
  ##   - ``true`` on success
  ##   - ``false`` on failure
  ##
  ## If called while logging is already active with the same filename, only the
  ## guid will be updated. If called while logging is already active with a
  ## different filename, `ovrHmdStopPerfLog <#ovrHmdStopPerfLog>`_ will be
  ## called, followed by `ovrHmdStartPerfLog <#ovrHmdStartPerfLog>`_.


proc ovrHmdStopPerfLog*(hmd: OvrHmd): OvrBool
  {.cdecl, dynlib: dllname, importc: "ovrHmd_StopPerfLog".}
  ## Stop performance logging.
