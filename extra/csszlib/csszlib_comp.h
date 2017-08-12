
#pragma once

#if defined (__cplusplus)
extern "C" {
#endif

#define CSSZ_OK 0

int csszlib_uncompress (unsigned char *dest, unsigned long *destLen, const unsigned char *source, unsigned long sourceLen);
int csszlib_compress2 (unsigned char *dest, unsigned long *destLen, const unsigned char *source, unsigned long sourceLen, int level);

#if defined (__cplusplus)
}
#endif