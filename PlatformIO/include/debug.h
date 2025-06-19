#ifndef DEBUG_H
#define DEBUG_H
#ifdef DEBUG_MODE // debug development settings
// calls to DEBUG will be replaced with Serial.print command
#define DEBUG(x) Serial.print(x)
// calls to DEBUGLN will be replaced with Serial.println command
#define DEBUGLN(x) Serial.println(x)
#define SERIAL_BEGIN(x) Serial.begin(x)
#else // production settings
// calls to DEBUG and DEBUGLN will be replaced with nothing
#define DEBUG(x)
#define DEBUGLN(x)
#define SERIAL_BEGIN(x)
#endif
#endif