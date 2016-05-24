/*
 * MATLAB Compiler: 4.13 (R2010a)
 * Date: Fri Jul 19 18:53:18 2013
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
#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_SwissSegment_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifndef LIB_SwissSegment_C_API
#define LIB_SwissSegment_C_API /* No special import/export declaration */
#endif

LIB_SwissSegment_C_API 
bool MW_CALL_CONV SwissSegmentInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
    {
        mclCtfStream ctfStream = 
            mclGetEmbeddedCtfStream(NULL, 
                                    3183757);
        if (ctfStream) {
            bResult = mclInitializeComponentInstanceEmbedded(   &_mcr_inst,
                                                                
                                                     &__MCC_SwissSegment_component_data,
                                                                true, 
                                                                NoObjectType, 
                                                                ExeTarget,
                                                                error_handler, 
                                                                print_handler,
                                                                ctfStream, 
                                                                3183757);
            mclDestroyStream(ctfStream);
        } else {
            bResult = 0;
        }
    }  
    if (!bResult)
    return false;
  return true;
}

LIB_SwissSegment_C_API 
bool MW_CALL_CONV SwissSegmentInitialize(void)
{
  return SwissSegmentInitializeWithHandlers(mclDefaultErrorHandler, 
                                            mclDefaultPrintHandler);
}
LIB_SwissSegment_C_API 
void MW_CALL_CONV SwissSegmentTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_SwissSegment_component_data.path_to_component = path_to_component; 
  if (!SwissSegmentInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "swissSegment", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  SwissSegmentTerminate();
#if defined( _MSC_VER)
  PostQuitMessage(0);
#endif
  mclTerminateApplication();
  return _retval;
}

#if defined( _MSC_VER)

#define argc __argc
#define argv __argv

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
#else
int main(int argc, const char **argv)

#endif
{
  if (!mclInitializeApplication(
    __MCC_SwissSegment_component_data.runtime_options, 
    __MCC_SwissSegment_component_data.runtime_option_count))
    return 0;

  return mclRunMain(run_main, argc, argv);
}
