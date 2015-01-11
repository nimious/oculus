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
# TODO gmp: documentation cleanup and formatting pass
# TODO gmp: set up library imports
# TODO gmp: add support for object field alignment

type
  ovrBool* = cchar


# Simple Math Structures #######################################################

type 
  ovrVector2i* = object
    ## A 2D vector with integer components.
    x*: cint
    y*: cint

  ovrSizei* = object
    ## A 2D size with integer components.
    w*: cint
    h*: cint

  ovrRecti* = object
    ## A 2D rectangle with a position and size. All components are integers.
    Pos*: ovrVector2i
    Size*: ovrSizei

  ovrQuatf* = object
    ## A quaternion rotation.
    x*: cfloat
    y*: cfloat
    z*: cfloat
    w*: cfloat

  ovrVector2f = object
    ## A 2D vector with float components.
    x*: cfloat
    y*: cfloat

  ovrVector3f* = object
    ## A 3D vector with float components.
    x*: cfloat
    y*: cfloat
    z*: cfloat

  ovrMatrix4f* = object } ;
    ## A 4x4 matrix with float elements.
    M*: array[4, array[4, cfloat]]

  ovrPosef* = object
    ## Position and orientation together.
    Orientation*: ovrQuatf
    Position*: ovrVector3f

  ovrPoseStatef* = object
    ## A full pose (rigid body) configuration with first and second derivatives.
    ThePose*: ovrPosef                                  ## The body's position and orientation.
    AngularVelocity*: ovrVector3f                       ## The body's angular velocity in radians per second.
    LinearVelocity*: ovrVector3f                        ## The body's velocity in meters per second.
    AngularAcceleration*: ovrVector3f                   ## The body's angular acceleration in radians per second per second.
    LinearAcceleration*: ovrVector3f                    ## The body's acceleration in meters per second per second.
    TimeInSeconds*: cdouble;                            ## Absolute time of this state sample.

  ovrFovPort* = object
    ## Field Of View (FOV) in tangent of the angle units.
    ## As an example, for a standard 90 degree vertical FOV, we would
    ## have: { UpTan = tan(90 degrees / 2), DownTan = tan(90 degrees / 2) }.
    UpTan*: cfloat                                      ## The tangent of the angle between the viewing vector
                                                        ## and the top edge of the field of view.
    DownTan*: cfloat                                    ## The tangent of the angle between the viewing vector
                                                        ## and the bottom edge of the field of view.
    LeftTan*: cfloat                                    ## The tangent of the angle between the viewing vector
                                                        ## and the left edge of the field of view.
    RightTan*: cfloat                                   ## The tangent of the angle between the viewing vector
                                                        ## and the right edge of the field of view.


# HMD Types ####################################################################

type
  ovrHmdType* {.size: sizeof(cint).} = enum
    ## Enumerates all HMD types that we support.
    ovrHmd_None = 0,
    ovrHmd_DK1 = 3,
    ovrHmd_DKHD = 4,
    ovrHmd_DK2 = 6,
    ovrHmd_Other        # Some HMD other then the one in the enumeration.

type
  ovrHmdCaps* {.size: sizeof(cint).} = enum
    ## HMD capability bits reported by device.

    # Read-only flags.
    ovrHmdCap_Present = 0x00000001,                     ## The HMD is plugged in and detected by the system.
    ovrHmdCap_Available = 0x00000002,                   ## The HMD and its sensor are available for ownership use.
                                                        ## i.e. it is not already owned by another application.
    ovrHmdCap_Captured = 0x00000004,                    ## Set to 'true' if we captured ownership of this HMD.

    # These flags are intended for use with the new driver display mode.
    ovrHmdCap_ExtendDesktop = 0x00000008,               ## (read only) Means the display driver is in compatibility mode.

    # Modifiable flags (through ovrHmd_SetEnabledCaps).
    ovrHmdCap_DisplayOff = 0x00000040,                  ## Turns off HMD screen and output (only if 'ExtendDesktop' is off).
    ovrHmdCap_LowPersistence = 0x00000080,              ## HMD supports low persistence mode.
    ovrHmdCap_DynamicPrediction = 0x00000200,           ## Adjust prediction dynamically based on internally measured latency.
    ovrHmdCap_DirectPentile = 0x00000400,               ## Write directly in pentile color mapping format
    ovrHmdCap_NoVSync = 0x00001000,                     ## Support rendering without VSync for debugging.
    ovrHmdCap_NoMirrorToWindow = 0x00002000,            ## Disables mirroring of HMD output to the window. This may improve
                                                        ## rendering performance slightly (only if 'ExtendDesktop' is off).

    # These flags are currently passed into the service. May change without notice.
    ovrHmdCap_Service_Mask = 0x000022F0,

    # These bits can be modified by ovrHmd_SetEnabledCaps.
    ovrHmdCap_Writable_Mask = 0x000032F0

type
  ovrTrackingCaps* {.size: sizeof(cint).} = enum
    ## Tracking capability bits reported by the device.
    ## Used with ovrHmd_ConfigureTracking.
    ovrTrackingCap_Orientation = 0x00000010,            ## Supports orientation tracking (IMU).
    ovrTrackingCap_MagYawCorrection = 0x00000020,       ## Supports yaw drift correction via a magnetometer or other means.
    ovrTrackingCap_Position = 0x00000040,               ## Supports positional tracking.
    ovrTrackingCap_Idle = 0x00000100                    ## Overrides the other flags. Indicates that the application
                                                        ## doesn't care about tracking settings. This is the internal
                                                        ## default before ovrHmd_ConfigureTracking is called.

type 
  ovrDistortionCaps* {.size: sizeof(cint).} = enum
    ## Distortion capability bits reported by device.
    ## Used with ovrHmd_ConfigureRendering and ovrHmd_CreateDistortionMesh.
    ovrDistortionCap_Chromatic = 0x00000001,            ## Supports chromatic aberration correction.
    ovrDistortionCap_TimeWarp = 0x00000002,             ## Supports timewarp.
    # 0x04 unused
    ovrDistortionCap_Vignette = 0x00000008,             ## Supports vignetting around the edges of the view.
    ovrDistortionCap_NoRestore = 0x00000010,            ## Do not save and restore the graphics and compute state when rendering distortion.
    ovrDistortionCap_FlipInput = 0x00000020,            ## Flip the vertical texture coordinate of input images.
    ovrDistortionCap_SRGB = 0x00000040,                 ## Assume input images are in sRGB gamma-corrected color space.
    ovrDistortionCap_Overdrive = 0x00000080,            ## Overdrive brightness transitions to reduce artifacts on DK2+ displays
    ovrDistortionCap_HqDistortion = 0x00000100,         ## High-quality sampling of distortion buffer for anti-aliasing
    ovrDistortionCap_LinuxDevFullscreen = 0x00000200,   ## Indicates window is fullscreen on a device when set. The SDK will automatically apply distortion mesh rotation if needed.
    ovrDistortionCap_ComputeShader = 0x00000400,        ## Using compute shader (DX11+ only)
    ovrDistortionCap_ProfileNoTimewarpSpinWaits = 0x00010000 ## Use when profiling with timewarp to remove false positives

type 
  ovrEyeType* {.size: sizeof(cint).} = enum 
    ## Specifies which eye is being used for rendering.
    ## This type explicitly does not include a third "NoStereo" option, as such is
    ## not required for an HMD-centered API.
    ovrEye_Left = 0,
    ovrEye_Right = 1,
    ovrEye_Count = 2

type 
  ovrHmdDesc* = object 
    ## This is a complete descriptor of the HMD.
    Handle*: ptr ovrHmdStruct                           ## Internal handle of this HMD.
    Type*: ovrHmdType                                   ## This HMD's type.
    ProductName*: cstring                               ## Name string describing the product: "Oculus Rift DK1", etc.
    Manufacturer*: cstring                              ## Name string describing the manufacturer.
    VendorId*: cshort                                   ## HID Vendor of the device
    ProductId*: cshort                                  ## ProductId of the device.
    SerialNumber*: array[24, char]                      ## Sensor (and display) serial number.
    FirmwareMajor*: cshort                              ## Sensor firmware version (major).
    FirmwareMinor*: cshort                              ## Sensor firmware version (minor).
    CameraFrustumHFovInRadians*: cfloat                 ## External tracking camera frustum dimensions (if present).
    CameraFrustumVFovInRadians*: cfloat                 ## External tracking camera frustum dimensions (if present).
    CameraFrustumNearZInMeters*: cfloat                 ## External tracking camera frustum dimensions (if present).
    CameraFrustumFarZInMeters*: cfloat                  ## External tracking camera frustum dimensions (if present).
    HmdCaps*: cuint                                     ## Capability bits described by ovrHmdCaps.
    TrackingCaps*: cuint                                ## Capability bits described by ovrTrackingCaps.
    DistortionCaps*: cuint                              ## Capability bits described by ovrDistortionCaps.
    DefaultEyeFov*: array[ovrEye_Count, ovrFovPort]     ## Recommended optical FOVs for the HMD.
    MaxEyeFov*: array[ovrEye_Count, ovrFovPort]         ## Maximum optical FOVs for the HMD.
    EyeRenderOrder*: array[ovrEye_Count, ovrEyeType]    ## Preferred eye rendering order for best performance.
                                                        ## Can help reduce latency on sideways-scanned screens.
    Resolution*: ovrSizei                               ## Resolution of the full HMD screen (both eyes) in pixels.
    WindowsPos*: ovrVector2i                            ## Location of the application window on the desktop (or 0,0).
    DisplayDeviceName*: cstring                         ## Display that the HMD should present on.
    DisplayId*: cint                                    ## Display identifier (MacOS only).

type 
  ovrHmd* = ptr ovrHmdDesc
    ## Simple type ovrHmd is used in ovrHmd_* calls.

type 
  ovrStatusBits* {.size: sizeof(cint).} = enum
    ## Bit flags describing the current status of sensor tracking.
    ovrStatus_OrientationTracked = 0x00000001,  ## Orientation is currently tracked (connected and in use).
    ovrStatus_PositionTracked = 0x00000002,     ## Position is currently tracked (false if out of range).
    ovrStatus_CameraPoseTracked = 0x00000004,   ## Camera pose is currently tracked.
    ovrStatus_PositionConnected = 0x00000020,   ## Position tracking hardware is connected.
    ovrStatus_HmdConnected = 0x00000080         ## HMD Display is available and connected.

type 
  ovrSensorData* = object
    ## Specifies a reading we can query from the sensor.
    Accelerometer*: ovrVector3f ## Acceleration reading in m/s^2.
    Gyro*: ovrVector3f          ## Rotation rate in rad/s.
    Magnetometer*: ovrVector3f  ## Magnetic field in Gauss.
    Temperature*: cfloat        ## Temperature of the sensor in degrees Celsius.
    TimeInSeconds*: cfloat      ## Time when the reported IMU reading took place, in seconds.


type 
  ovrTrackingState* = object
    ## Tracking state at a given absolute time (describes predicted HMD pose etc).
    ## Returned by ovrHmd_GetTrackingState.
    HeadPose*: ovrPoseStatef            ## Predicted head pose (and derivatives) at the requested absolute time.
                                        ## The look-ahead interval is equal to (HeadPose.TimeInSeconds - RawSensorData.TimeInSeconds).
    CameraPose*: ovrPosef               ## Current pose of the external camera (if present).
                                        ## This pose includes camera tilt (roll and pitch). For a leveled coordinate
                                        ## system use LeveledCameraPose.
    LeveledCameraPose*: ovrPosef        ## Camera frame aligned with gravity.
                                        ## This value includes position and yaw of the camera, but not roll and pitch.
                                        ## It can be used as a reference point to render real-world objects in the correct location.
    RawSensorData*: ovrSensorData       ## The most recent sensor data received from the HMD.
    StatusFlags*: cuint                 ## Tracking status described by ovrStatusBits.

    # 0.4.1
    LastVisionProcessingTime*: cdouble  ## Measures the time from receiving the camera frame until vision CPU processing completes.

    # 0.4.3
    LastVisionFrameLatency*: cdouble    ## Measures the time from exposure until the pose is available for the frame, including processing time.
    LastCameraFrameCounter*: uint32_t   ## Tag the vision processing results to a certain frame counter number.


type 
  ovrFrameTiming* = object 
    ## Frame timing data reported by ovrHmd_BeginFrameTiming() or ovrHmd_BeginFrame().
    DeltaSeconds*: cfloat ## The amount of time that has passed since the previous frame's
                          ## ThisFrameSeconds value (usable for movement scaling).
                          ## This will be clamped to no more than 0.1 seconds to prevent
                          ## excessive movement after pauses due to loading or initialization.
                          ##
                          ## It is generally expected that the following holds:
                          ## ThisFrameSeconds < TimewarpPointSeconds < NextFrameSeconds < 
                          ## EyeScanoutSeconds[EyeOrder[0]] <= ScanoutMidpointSeconds <= EyeScanoutSeconds[EyeOrder[1]].

    ThisFrameSeconds*: cdouble ## Absolute time value when rendering of this frame began or is expected to
                              ## begin. Generally equal to NextFrameSeconds of the previous frame. Can be used
                              ## for animation timing.
    TimewarpPointSeconds*: cdouble## Absolute point when IMU expects to be sampled for this frame.
    NextFrameSeconds*: cdouble ## Absolute time when frame Present followed by GPU Flush will finish and the next frame begins.
    ScanoutMidpointSeconds*: cdouble  ## Time when half of the screen will be scanned out. Can be passed as an absolute time
                                ## to ovrHmd_GetTrackingState() to get the predicted general orientation.
    EyeScanoutSeconds*: array[2, cdouble]## Timing points when each eye will be scanned out to display. Used when rendering each eye.


type 
  ovrEyeRenderDesc* = object 
    ## Rendering information for each eye. Computed by either ovrHmd_ConfigureRendering()
    ## or ovrHmd_GetRenderDesc() based on the specified FOV. Note that the rendering viewport
    ## is not included here as it can be specified separately and modified per frame through:
    ##    (a) ovrHmd_GetRenderScaleAndOffset in the case of client rendered distortion,
    ## or (b) passing different values via ovrTexture in the case of SDK rendered distortion.
    Eye*: ovrEyeType        ## The eye index this instance corresponds to.
    Fov*: ovrFovPort        ## The field of view.
    DistortedViewport*: ovrRecti ## Distortion viewport.
    PixelsPerTanAngleAtCenter*: ovrVector2f ## How many display pixels will fit in tan(angle) = 1.
    HmdToEyeViewOffset*: ovrVector3f ## Translation to be applied to view matrix for each eye offset.


# Platform-independent Rendering Configuration #################################

# These types are used to hide platform-specific details when passing render
# device, OS, and texture data to the API. The benefit of having these wrappers
# versus platform-specific API functions is that they allow game glue code to be
# portable. A typical example is an engine that has multiple back ends, say GL
# and D3D. Portable code that calls these back ends may also use LibOVR. To do
# this, back ends can be modified to return portable types such as ovrTexture
# and ovrRenderAPIConfig.

type 
  ovrRenderAPIType* {.size: sizeof(cint).} = enum 
    ovrRenderAPI_None,
    ovrRenderAPI_OpenGL,
    ovrRenderAPI_Android_GLES, # May include extra native window pointers, etc.
    ovrRenderAPI_D3D9, ovrRenderAPI_D3D10, ovrRenderAPI_D3D11, 
    ovrRenderAPI_Count

type                        #OVR_ALIGNAS(8)
  ovrRenderAPIConfigHeader* = object 
    # Platform-independent part of rendering API-configuration data.
    # It is a part of ovrRenderAPIConfig, passed to ovrHmd_Configure.
    API*: ovrRenderAPIType
    BackBufferSize*: ovrSizei           # Previously named RTSize.
    Multisample*: cint

type                        #OVR_ALIGNAS(8)
  ovrRenderAPIConfig* = object 
    ## Contains platform-specific information for rendering.
    Header*: ovrRenderAPIConfigHeader
    PlatformData*: array[8, uintptr_t]

type                        #OVR_ALIGNAS(8)
  ovrTextureHeader* = object 
    # Platform-independent part of the eye texture descriptor.
    # It is a part of ovrTexture, passed to ovrHmd_EndFrame.
    # If RenderViewport is all zeros then the full texture will be used.
    API*: ovrRenderAPIType
    TextureSize*: ovrSizei
    RenderViewport*: ovrRecti # Pixel viewport in texture that holds eye image.
    _PAD0_*: uint32_t

type                        #OVR_ALIGNAS(8)
  ovrTexture* = object 
    # Contains platform-specific information about a texture.
    Header*: ovrTextureHeader
    PlatformData*: array[8, uintptr_t]


# API Interfaces ###############################################################

# Basic steps to use the API:
#
# Setup:
#  * ovrInitialize()
#  * ovrHMD hmd = ovrHmd_Create(0)
#  * Use hmd members and ovrHmd_GetFovTextureSize() to determine graphics configuration.
#  * Call ovrHmd_ConfigureTracking() to configure and initialize tracking.
#  * Call ovrHmd_ConfigureRendering() to setup graphics for SDK rendering,
#    which is the preferred approach.
#    Please refer to "Client Distorton Rendering" below if you prefer to do that instead.
#  * If the ovrHmdCap_ExtendDesktop flag is not set, then use ovrHmd_AttachToWindow to
#    associate the relevant application window with the hmd.
#  * Allocate render target textures as needed.
#
# Game Loop:
#  * Call ovrHmd_BeginFrame() to get the current frame timing information.
#  * Render each eye using ovrHmd_GetEyePoses or ovrHmd_GetHmdPosePerEye to get
#    the predicted hmd pose and each eye pose.
#  * Call ovrHmd_EndFrame() to render the distorted textures to the back buffer
#    and present them on the hmd.
#
# Shutdown:
#  * ovrHmd_Destroy(hmd)
#  * ovr_Shutdown()

proc ovr_InitializeRenderingShim*(): ovrBool
  ## Initializes the rendering shim appart from everything else in LibOVR. This
  ## may be helpful if the application prefers to avoid creating any OVR
  ## resources (allocations, service connections, etc) at this point. Does not
  ## bring up anything within LibOVR except the necessary hooks to enable the
  ## Direct-to-Rift functionality.
  ##
  ## Either ovr_InitializeRenderingShim() or ovr_Initialize() must be called
  ## before any Direct3D or OpenGL initilization is done by applictaion
  ## (creation devices, etc). ovr_Initialize() must still be called after to use
  ## the rest of LibOVR APIs.

proc ovr_Initialize*(): ovrBool
  ## Library init/shutdown, must be called around all other OVR code. No other
  ## functions calls besides ovr_InitializeRenderingShim are allowed before
  ## ovr_Initialize succeeds or after ovr_Shutdown. Initializes all Oculus
  ## functionality.

proc ovr_Shutdown*()
  ## Shuts down all Oculus functionality.

proc ovr_GetVersionString*(): cstring
  ## Returns version string representing libOVR version. Static, so string
  ## remains valid for app lifespan.

proc ovrHmd_Detect*(): cint
  ## Detects or re-detects HMDs and reports the total number detected. Users can
  ## get information about each HMD by calling ovrHmd_Create with an index.

proc ovrHmd_Create*(index: cint): ovrHmd
  ## Creates a handle to an HMD which doubles as a description structure. Index
  ## can be [0..(ovrHmd_Detect() - 1)]. Index mappings can cange after each
  ## ovrHmd_Detect call. If not null, then the returned handle must be freed
  ## with ovrHmd_Destroy.

proc ovrHmd_Destroy*(hmd: ovrHmd)
  ## Destroys a handle to an HMD.

proc ovrHmd_CreateDebug*(`type`: ovrHmdType): ovrHmd
  ## Creates a 'fake' HMD used for debugging only. This is not tied to specific
  ## hardware, but may be used to debug some of the related rendering.

proc ovrHmd_GetLastError*(hmd: ovrHmd): cstring
  ## Returns last error for HMD state. Returns null for no error. String is
  ## valid until next call or GetLastError or HMD is destroyed. Pass null hmd to
  ## get global errors (during create etc).

proc ovrHmd_AttachToWindow*(hmd: ovrHmd; window: pointer;
                            destMirrorRect: ptr ovrRecti;
                            sourceRenderTargetRect: ptr ovrRecti): ovrBool
  ## Platform specific function to specify the application window whose output
  ## will be displayed on the HMD. Only used if the ovrHmdCap_ExtendDesktop flag
  ## is false.
  ##
  ## Windows: SwapChain associated with this window will be displayed on the
  ## HMD. Specify 'destMirrorRect' in window coordinates to indicate an area of
  ## the render target output that will be mirrored from
  ## 'sourceRenderTargetRect'. Null pointers mean "full size".
  ##
  ## Note: Source and dest mirror rects are not yet implemented.

proc ovrHmd_GetEnabledCaps*(hmd: ovrHmd): cuint
  ## Returns capability bits that are enabled at this time as described by
  ## ovrHmdCaps. Note that this value is different font ovrHmdDesc::HmdCaps,
  ## which describes what capabilities are available for that HMD.

proc ovrHmd_SetEnabledCaps*(hmd: ovrHmd; hmdCaps: cuint)
  ## Modifies capability bits described by ovrHmdCaps that can be modified, such
  ## as ovrHmdCap_LowPersistance.


# Tracking Interface ###########################################################

# All tracking interface functions are thread-safe, allowing tracking state to
# be sampled from different threads.

proc ovrHmd_ConfigureTracking*(hmd: ovrHmd; supportedTrackingCaps: cuint;
                               requiredTrackingCaps: cuint): ovrBool
  ## ConfigureTracking starts sensor sampling, enabling specified capabilities,
  ## described by ovrTrackingCaps.
  ## - supportedTrackingCaps specifies support that is requested. The function
  ##   will succeed even if these caps are not available (i.e. sensor or camera
  ##   is unplugged). Support will automatically be enabled if such device is
  ##   plugged in later. Software should check ovrTrackingState.StatusFlags for
  ##   real-time status.
  ## - requiredTrackingCaps specify sensor capabilities required at the time of
  ##   the call. If they are not available, the function will fail. Pass 0 if
  ##   only specifying supportedTrackingCaps.
  ## - Pass 0 for both supportedTrackingCaps and requiredTrackingCaps to disable
  ##   tracking.

proc ovrHmd_RecenterPose*(hmd: ovrHmd)
  ## Re-centers the sensor orientation. Normally this will recenter the (x,y,z)
  ## translational components and the yaw component of orientation.

proc ovrHmd_GetTrackingState*(hmd: ovrHmd; absTime: cdouble): ovrTrackingState
  ## Returns tracking state reading based on the specified absolute system time.
  ## Pass an absTime value of 0.0 to request the most recent sensor reading. In
  ## this case both PredictedPose and SamplePose will have the same value.
  ## ovrHmd_GetEyePoses relies on this function internally. This may also be
  ## used for more refined timing of FrontBuffer rendering logic, etc.


# Graphics Setup ###############################################################

proc ovrHmd_GetFovTextureSize*(hmd: ovrHmd; eye: ovrEyeType; fov: ovrFovPort;
                               pixelsPerDisplayPixel: cfloat): ovrSizei
  ## Calculates the recommended texture size for rendering a given eye within
  ## the HMD with a given FOV cone. Higher FOV will generally require larger
  ## textures to maintain quality.
  ## - pixelsPerDisplayPixel specifies the ratio of the number of render target
  ##   pixels to display pixels at the center of distortion. 1.0 is the default
  ##   value. Lower values can improve performance.


# Rendering API Thread Safety ##################################################

# All of rendering functions including the configure and frame functions are
# *NOT thread safe*. It is ok to use ConfigureRendering on one thread and handle
# frames on another thread, but explicit synchronization must be done since
# functions that depend on configured state are not reentrant.
#
# As an extra requirement, any of the following calls must be done on the render
# thread, which is the same thread that calls ovrHmd_BeginFrame or
# ovrHmd_BeginFrameTiming.
#    - ovrHmd_EndFrame
#    - ovrHmd_GetEyeTimewarpMatrices


# SDK Distortion Rendering Functions ###########################################

# These functions support rendering of distortion by the SDK through direct
# access to the underlying rendering API, such as D3D or GL. This is the
# recommended approach since it allows better support for future Oculus
# hardware, and enables a range of low-level optimizations.

proc ovrHmd_ConfigureRendering*(hmd: ovrHmd;
       apiConfig: ptr ovrRenderAPIConfig;
       distortionCaps: cuint;
       eyeFovIn: array[2, ovrFovPort];
       eyeRenderDescOut: array[2, ovrEyeRenderDesc]): ovrBool
  ## Configures rendering and fills in computed render parameters. This function
  ## can be called multiple times to change rendering settings. eyeRenderDescOut
  ## is a pointer to an array of two ovrEyeRenderDesc structs that are used to
  ## return complete rendering information for each eye.
  ##  - apiConfig provides D3D/OpenGL specific parameters. Pass null
  ##    to shutdown rendering and release all resources.
  ##  - distortionCaps describe desired distortion settings.

proc ovrHmd_BeginFrame*(hmd: ovrHmd; frameIndex: cuint): ovrFrameTiming
  ## Begins a frame, returning timing information. This should be called at the
  ## beginning of the game rendering loop (on the render thread). Pass 0 for the
  ## frame index if not using ovrHmd_GetFrameTiming.

proc ovrHmd_EndFrame*(hmd: ovrHmd; renderPose: array[2, ovrPosef];
       eyeTexture: array[2, ovrTexture])
  ## Ends a frame, submitting the rendered textures to the frame buffer.
  ## - RenderViewport within each eyeTexture can change per frame if necessary.
  ## - 'renderPose' will typically be the value returned from ovrHmd_GetEyePoses,
  ##   ovrHmd_GetHmdPosePerEye but can be different if a different head pose was
  ##   used for rendering.
  ## - This may perform distortion and scaling internally, assuming is it not
  ##   delegated to another thread.
  ## - Must be called on the same thread as BeginFrame.
  ## - *** This Function will call Present/SwapBuffers and potentially wait for
  ##   GPU Sync ***.

proc ovrHmd_GetEyePoses*(hmd: ovrHmd; frameIndex: cuint;
       hmdToEyeViewOffset: array[2, ovrVector3f];
       outEyePoses: array[2, ovrPosef];
       outHmdTrackingState: ptr ovrTrackingState)
  ## Returns predicted head pose in outHmdTrackingState and offset eye poses in
  ## outEyePoses as an atomic operation. Caller need not worry about applying
  ## HmdToEyeViewOffset to the returned outEyePoses variables.
  ## - Thread-safe function where caller should increment frameIndex with every
  ##   frame and pass the index where applicable to functions called on the
  ##   rendering thread.
  ## - hmdToEyeViewOffset[2] can be ovrEyeRenderDesc.HmdToEyeViewOffset returned
  ##   from ovrHmd_ConfigureRendering or ovrHmd_GetRenderDesc. For monoscopic
  ##   rendering, use a vector that is the average of the two vectors for both
  ##   eyes.
  ## - If frameIndex is not being used, pass in 0.
  ## - Assuming outEyePoses are used for rendering, it should be passed into
  ##   ovrHmd_EndFrame.
  ## - If called doesn't need outHmdTrackingState, it can be NULL

proc ovrHmd_GetHmdPosePerEye*(hmd: ovrHmd; eye: ovrEyeType): ovrPosef
  ## Function was previously called ovrHmd_GetEyePose
  ## Returns the predicted head pose to use when rendering the specified eye.
  ## - Important: Caller must apply HmdToEyeViewOffset before using ovrPosef for
  ##   rendering
  ## - Must be called between ovrHmd_BeginFrameTiming and ovrHmd_EndFrameTiming.
  ## - If the pose is used for rendering the eye, it should be passed to
  ##   ovrHmd_EndFrame.
  ## - Parameter 'eye' is used for prediction timing only


# Client Distortion Rendering Functions ########################################

# These functions provide the distortion data and render timing support
# necessary to allow client rendering of distortion. Client-side rendering
# involves the following steps:
#
# 1. Setup ovrEyeDesc based on the desired texture size and FOV.
#    Call ovrHmd_GetRenderDesc to get the necessary rendering parameters for
#    each eye.
#
# 2. Use ovrHmd_CreateDistortionMesh to generate the distortion mesh.
#
# 3. Use ovrHmd_BeginFrameTiming, ovrHmd_GetEyePoses, and
#    ovrHmd_BeginFrameTiming in the rendering loop to obtain timing and
#    predicted head orientation when rendering each eye.
#
# When using timewarp, use ovr_WaitTillTime after the rendering and gpu flush,
# followed by ovrHmd_GetEyeTimewarpMatrices to obtain the timewarp matrices used
# by the distortion pixel shader. This will minimize latency.

proc ovrHmd_GetRenderDesc*(hmd: ovrHmd; eyeType: ovrEyeType; fov: ovrFovPort): ovrEyeRenderDesc
  ## Computes the distortion viewport, view adjust, and other rendering
  ## parameters for the specified eye. This can be used instead of
  ## ovrHmd_ConfigureRendering to do setup for client rendered distortion.


type 
  ovrDistortionVertex* = object
    ## Describes a vertex used by the distortion mesh. This is intended to be
    ## converted into the engine-specific format. Some fields may be unused
    ## based on the ovrDistortionCaps flags selected. TexG and TexB, for
    ## example, are not used if chromatic correction is not requested.
    ScreenPosNDC*: ovrVector2f ## [-1,+1],[-1,+1] over the entire framebuffer.
    TimeWarpFactor*: cfloat ## Lerp factor between time-warp matrices. Can be encoded in Pos.z.
    VignetteFactor*: cfloat ## Vignette fade factor. Can be encoded in Pos.w.
    TanEyeAnglesR*: ovrVector2f ## The tangents of the horizontal and vertical eye angles for the red channel.
    TanEyeAnglesG*: ovrVector2f ## The tangents of the horizontal and vertical eye angles for the green channel.
    TanEyeAnglesB*: ovrVector2f ## The tangents of the horizontal and vertical eye angles for the blue channel.

type 
  ovrDistortionMesh* = object
    ## Describes a full set of distortion mesh data, filled in by
    ## ovrHmd_CreateDistortionMesh. Contents of this data structure, if not
    ## null, should be freed by ovrHmd_DestroyDistortionMesh.
    pVertexData*: ptr ovrDistortionVertex ## The distortion vertices representing each point in the mesh.
    pIndexData*: ptr cushort ## Indices for connecting the mesh vertices into polygons.
    VertexCount*: cuint     ## The number of vertices in the mesh.
    IndexCount*: cuint      ## The number of indices in the mesh.

proc ovrHmd_CreateDistortionMesh*(hmd: ovrHmd; eyeType: ovrEyeType;
                                  fov: ovrFovPort; distortionCaps: cuint;
                                  meshData: ptr ovrDistortionMesh): ovrBool
  ## Generate distortion mesh per eye. Distortion capabilities will depend on
  ## 'distortionCaps' flags. Users should render using the appropriate shaders
  ## based on their settings. Distortion mesh data will be allocated and written
  ## into the ovrDistortionMesh data structure, which should be explicitly freed
  ## with ovrHmd_DestroyDistortionMesh.
  ##
  ## Users should call ovrHmd_GetRenderScaleAndOffset to get uvScale and Offset
  ## values for rendering. The function shouldn't fail unless theres is a
  ## configuration or memory error, in which case ovrDistortionMesh values will
  ## be set to null. This is the only function in the SDK reliant on eye relief,
  ## currently imported from profiles, or overridden here.

proc ovrHmd_CreateDistortionMeshDebug*(hmddesc: ovrHmd; eyeType: ovrEyeType;
    fov: ovrFovPort; distortionCaps: cuint; meshData: ptr ovrDistortionMesh;
    debugEyeReliefOverrideInMetres: cfloat): ovrBool

proc ovrHmd_DestroyDistortionMesh*(meshData: ptr ovrDistortionMesh)
  ## Used to free the distortion mesh allocated by
  ## ovrHmd_GenerateDistortionMesh. meshData elements are set to null and zeroes
  ## after the call.

proc ovrHmd_GetRenderScaleAndOffset*(fov: ovrFovPort; textureSize: ovrSizei;
                                     renderViewport: ovrRecti;
                                     uvScaleOffsetOut: array[2, ovrVector2f])
  ## Computes updated 'uvScaleOffsetOut' to be used with a distortion if render
  ## target size or viewport changes after the fact. This can be used to adjust
  ## render size every frame if desired.

proc ovrHmd_GetFrameTiming*(hmd: ovrHmd; frameIndex: cuint): ovrFrameTiming
  ## Thread-safe timing function for the main thread. Caller should increment
  ## frameIndex with every frame and pass the index where applicable to
  ## functions called on the rendering thread.

proc ovrHmd_BeginFrameTiming*(hmd: ovrHmd; frameIndex: cuint): ovrFrameTiming
  ## Called at the beginning of the frame on the rendering thread. Pass
  ## frameIndex == 0 if ovrHmd_GetFrameTiming isn't being used. Otherwise, pass
  ## the same frame index as was used for GetFrameTiming on the main thread.

proc ovrHmd_EndFrameTiming*(hmd: ovrHmd)
  ## Marks the end of client distortion rendered frame, tracking the necessary
  ## timing information. This function must be called immediately after
  ## Present/SwapBuffers + GPU sync. GPU sync is important before this call to
  ## reduce latency and ensure proper timing.

proc ovrHmd_ResetFrameTiming*(hmd: ovrHmd; frameIndex: cuint)
  ## Initializes and resets frame time tracking. This is typically not
  ## necessary, but is helpful if game changes vsync state or video mode.
  ## vsync is assumed to be on if this isn't called. Resets internal frame
  ## index to the specified number.

proc ovrHmd_GetEyeTimewarpMatrices*(hmd: ovrHmd; eye: ovrEyeType;
                                    renderPose: ovrPosef;
                                    twmOut: array[2, ovrMatrix4f])
  ## Computes timewarp matrices used by distortion mesh shader, these are used
  ## to adjust for head orientation change since the last call to
  ## ovrHmd_GetEyePoses when rendering this eye.
  ##
  ## The ovrDistortionVertex::TimeWarpFactor is used to blend between the
  ## matrices, usually representing two different sides of the screen. Must be
  ## called on the same thread as ovrHmd_BeginFrameTiming.

proc ovrHmd_GetEyeTimewarpMatricesDebug*(hmd: ovrHmd; eye: ovrEyeType;
    renderPose: ovrPosef; twmOut: array[2, ovrMatrix4f]; 
    debugTimingOffsetInSeconds: cdouble)


# Stateless math setup functions ###############################################

proc ovrMatrix4f_Projection*(fov: ovrFovPort; znear: cfloat; zfar: cfloat;
                              rightHanded: ovrBool): ovrMatrix4f
  ## Used to generate projection from ovrEyeDesc::Fov.

proc ovrMatrix4f_OrthoSubProjection*(projection: ovrMatrix4f; 
                                      orthoScale: ovrVector2f; 
                                      orthoDistance: cfloat; 
                                      hmdToEyeViewOffsetX: cfloat): ovrMatrix4f
  ## Used for 2D rendering, Y is down.
  ## orthoScale = 1.0f / pixelsPerTanAngleAtCenter
  ## orthoDistance = distance from camera, such as 0.8m

proc ovr_GetTimeInSeconds*(): cdouble
  ## Returns global, absolute high-resolution time in seconds. This is the same
  ## value as used in sensor messages.

proc ovr_WaitTillTime*(absTime: cdouble): cdouble
  ## Waits until the specified absolute time.


# Latency Test interface #######################################################

proc ovrHmd_ProcessLatencyTest*(hmd: ovrHmd; rgbColorOut: array[3, cuchar]): ovrBool
  ## Does latency test processing and returns 'TRUE' if specified rgb color
  ## should be used to clear the screen.

proc ovrHmd_GetLatencyTestResult*(hmd: ovrHmd): cstring
  ## Returns non-null string once with latency test result, when it is
  ## available. Buffer is valid until next call.

proc ovrHmd_GetLatencyTest2DrawColor*(hmddesc: ovrHmd;
                                      rgbColorOut: array[3, cuchar]): ovrBool
  ## Returns the latency testing color in rgbColorOut to render when using a DK2
  ## Returns false if this feature is disabled or not-applicable (e.g. DK1)


# Health and Safety Warning Display interface ##################################

type 
  ovrHSWDisplayState* = object 
    ## Used by ovrhmd_GetHSWDisplayState to report the current display state.
    Displayed*: ovrBool ## If true then the warning should be currently visible
                        ## and the following variables have meaning. Else there
                        ## is no warning being displayed for this application on
                        ## the given HMD. True if the Health&Safety Warning is
                        ## currently displayed.
    StartTime*: cdouble     ## Absolute time when the warning was first displayed. See ovr_GetTimeInSeconds().
    DismissibleTime*: cdouble ## Earliest absolute time when the warning can be dismissed. May be a time in the past.


proc ovrHmd_GetHSWDisplayState*(hmd: ovrHmd; hasWarningState: ptr ovrHSWDisplayState)
  ## Returns the current state of the HSW display. If the application is doing
  ## the rendering of the HSW display then this function serves to indicate that
  ## the warning should be currently displayed. If the application is using
  ## SDK-based eye rendering then the SDK by default automatically handles the
  ## drawing of the HSW display.
  ##
  ## An application that uses application-based eye rendering should use this
  ## function to know when to start drawing the HSW display itself and can
  ## optionally use it in conjunction with ovrhmd_DismissHSWDisplay as described
  ## below.
  ##
  ## TODO gmp: adapt example to nim
  ##
  ## Example usage for application-based rendering:
  ##    bool HSWDisplayCurrentlyDisplayed = false; // global or class member variable
  ##    ovrHSWDisplayState hswDisplayState;
  ##    ovrhmd_GetHSWDisplayState(Hmd, &hswDisplayState);
  ##
  ##    if (hswDisplayState.Displayed && !HSWDisplayCurrentlyDisplayed) {
  ##        <insert model into the scene that stays in front of the user>
  ##        HSWDisplayCurrentlyDisplayed = true;
  ##    }

proc ovrHmd_DismissHSWDisplay*(hmd: ovrHmd): ovrBool
  ## Dismisses the HSW display if the warning is dismissible and the earliest
  ## dismissal time has occurred. Returns true if the display is valid and could
  ## be dismissed. The application should recognize that the HSW display is
  ## being displayed (via ovrhmd_GetHSWDisplayState) and if so then call this
  ## function when the appropriate user input to dismiss the warning occurs.
  ##
  ## TODO gmp: adapt example to nim
  ##
  ## Example usage :
  ##    void ProcessEvent(int key) {
  ##        if (key == escape) {
  ##            ovrHSWDisplayState hswDisplayState;
  ##            ovrhmd_GetHSWDisplayState(hmd, &hswDisplayState);
  ##
  ##            if (hswDisplayState.Displayed && ovrhmd_DismissHSWDisplay(hmd)) {
  ##                <remove model from the scene>
  ##                HSWDisplayCurrentlyDisplayed = false;
  ##            }
  ##        }
  ##    }

proc ovrHmd_GetBool*(hmd: ovrHmd; propertyName: cstring; defaultVal: ovrBool): ovrBool
  ## Get boolean property. Returns first element if property is a boolean array.
  ## Returns defaultValue if property doesn't exist.

proc ovrHmd_SetBool*(hmd: ovrHmd; propertyName: cstring; value: ovrBool): ovrBool
  ## Modify bool property; false if property doesn't exist or is readonly.

proc ovrHmd_GetInt*(hmd: ovrHmd; propertyName: cstring; defaultVal: cint): cint
  ## Get integer property. Returns first element if property is an integer array.
  ## Returns defaultValue if property doesn't exist.

proc ovrHmd_SetInt*(hmd: ovrHmd; propertyName: cstring; value: cint): ovrBool
  ## Modify integer property; false if property doesn't exist or is readonly.

proc ovrHmd_GetFloat*(hmd: ovrHmd; propertyName: cstring; defaultVal: cfloat): cfloat
  ## Get float property. Returns first element if property is a float array.
  ## Returns defaultValue if property doesn't exist.

proc ovrHmd_SetFloat*(hmd: ovrHmd; propertyName: cstring; value: cfloat): ovrBool
  ## Modify float property; false if property doesn't exist or is readonly.

proc ovrHmd_GetFloatArray*(hmd: ovrHmd; propertyName: cstring;
                            values: ptr cfloat; arraySize: cuint): cuint
  ## Get float[] property. Returns the number of elements filled in, 0 if
  ## property doesn't exist. Maximum of arraySize elements will be written.

proc ovrHmd_SetFloatArray*(hmd: ovrHmd; propertyName: cstring;
                            values: ptr cfloat; arraySize: cuint): ovrBool
  ## Modify float[] property; false if property doesn't exist or is readonly.

proc ovrHmd_GetString*(hmd: ovrHmd; propertyName: cstring; defaultVal: cstring): cstring
  ## Get string property. Returns first element if property is a string array.
  ## Returns defaultValue if property doesn't exist.
  ## String memory is guaranteed to exist until next call to GetString or
  ## GetStringArray, or HMD is destroyed.

proc ovrHmd_SetString*(hmddesc: ovrHmd; propertyName: cstring; value: cstring): ovrBool
  ## Set string property


# Logging ######################################################################

proc ovrHmd_StartPerfLog*(hmd: ovrHmd; fileName: cstring; userData1: cstring): ovrBool
  ## Start performance logging. guid is optional and if included is written with
  ## each file entry. If called while logging is already active with the same
  ## filename, only the guid will be updated If called while logging is already
  ## active with a different filename, ovrHmd_StopPerfLog() will be called,
  ## followed by ovrHmd_StartPerfLog()

proc ovrHmd_StopPerfLog*(hmd: ovrHmd): ovrBool
  ## Stop performance logging.
