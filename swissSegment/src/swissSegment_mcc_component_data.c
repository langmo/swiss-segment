/*
 * MATLAB Compiler: 4.13 (R2010a)
 * Date: Fri Jul 19 18:53:19 2013
 * Arguments: "-B" "macro_default" "-o" "SwissSegment" "-W"
 * "WinMain:SwissSegment" "-T" "link:exe" "-d" "U:\Marius Oscillator\new
 * system\imageAnalysis\swissSegment\SwissSegment\src" "-w"
 * "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w"
 * "enable:demo_license" "-v" "U:\Marius Oscillator\new
 * system\imageAnalysis\swissSegment\swissSegment.m" "-a" "U:\Marius
 * Oscillator\new system\imageAnalysis\swissSegment\background.png" "-a"
 * "U:\Marius Oscillator\new system\imageAnalysis\swissSegment\icon.png" "-a"
 * "U:\Marius Oscillator\new system\imageAnalysis\swissSegment\matterhorn.jpg"
 * "-a" "U:\Marius Oscillator\new
 * system\imageAnalysis\swissSegment\segmentImage.mexw64" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_SwissSegment_session_key[] = {
    '2', '8', 'C', '6', 'A', '7', '1', '3', '1', '8', '1', '1', '6', '8', 'E',
    '0', '3', '2', '8', '3', '2', '8', 'B', 'E', '7', '2', 'A', 'F', 'E', 'B',
    '1', '6', '6', '1', 'F', 'B', '4', '0', '5', '9', 'D', '9', 'E', '3', '1',
    '8', 'D', '2', '6', '3', 'B', '1', '8', '5', '5', '7', '5', 'C', '0', 'C',
    '1', '2', 'D', '3', '8', '2', 'E', '6', '3', '9', '0', '3', 'A', '7', '9',
    'D', '4', 'C', 'F', 'B', 'D', 'E', 'B', 'E', '3', '5', 'D', '5', '3', '0',
    '6', '5', '1', '1', '2', 'D', 'F', '7', '4', '3', '3', '7', 'D', '9', 'E',
    '3', '3', '1', '3', '3', '5', '5', '4', '6', 'C', '4', 'B', '7', '8', '2',
    '9', 'C', '6', '6', '7', '9', '3', 'D', '5', 'F', 'C', '4', '1', 'E', 'B',
    '7', 'A', '2', 'C', 'B', '7', 'C', 'C', '2', '9', 'B', '3', '3', '3', 'D',
    '2', '4', '0', '4', 'A', 'C', 'C', 'A', '3', '9', '3', '0', '4', 'F', '4',
    'B', '4', '4', '4', '2', '7', 'E', 'B', '3', '9', 'A', 'E', 'A', '2', '3',
    '3', '1', '8', 'C', 'E', '9', 'F', '0', 'A', '9', '9', '7', 'E', 'A', '5',
    'A', '5', '2', '6', 'A', 'E', '5', '8', '0', 'E', '9', '3', '8', 'C', '9',
    '5', '3', '8', '8', '4', '9', 'C', 'A', '2', 'A', 'E', '3', 'E', 'A', '7',
    '6', '8', '5', '0', '5', '4', 'D', '7', '6', 'A', 'F', '9', 'D', '9', '3',
    '0', '6', '5', '4', 'D', 'E', 'C', 'A', '4', '2', '2', '8', '7', 'B', '8',
    '7', '\0'};

const unsigned char __MCC_SwissSegment_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_SwissSegment_matlabpath_data[] = 
  { "SwissSegment/", "$TOOLBOXDEPLOYDIR/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/winfun/net/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/",
    "toolbox/images/colorspaces/", "toolbox/images/images/",
    "toolbox/images/imuitools/", "toolbox/images/iptformats/",
    "toolbox/images/iptutils/", "toolbox/shared/imageslib/" };

static const char * MCC_SwissSegment_classpath_data[] = 
  { "java/jar/toolbox/images.jar" };

static const char * MCC_SwissSegment_libpath_data[] = 
  { "bin/win64/" };

static const char * MCC_SwissSegment_app_opts_data[] = 
  { "" };

static const char * MCC_SwissSegment_run_opts_data[] = 
  { "" };

static const char * MCC_SwissSegment_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_SwissSegment_component_data = { 

  /* Public key data */
  __MCC_SwissSegment_public_key,

  /* Component name */
  "SwissSegment",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_SwissSegment_session_key,

  /* Component's MATLAB Path */
  MCC_SwissSegment_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  45,

  /* Component's Java class path */
  MCC_SwissSegment_classpath_data,
  /* Number of directories in the Java class path */
  1,

  /* Component's load library path (for extra shared libraries) */
  MCC_SwissSegment_libpath_data,
  /* Number of directories in the load library path */
  1,

  /* MCR instance-specific runtime options */
  MCC_SwissSegment_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_SwissSegment_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "SwissSegment_B21DD9FA73A7C00733E59A4D78484B4E",

  /* MCR warning status data */
  MCC_SwissSegment_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


