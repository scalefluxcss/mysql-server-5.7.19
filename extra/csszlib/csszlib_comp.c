#include "csszlib.h"
#include "csszlib_comp.h"

int csszlib_uncompress (unsigned char *dest, unsigned long *destLen, const unsigned char *source, unsigned long sourceLen)
{
	return uncompress(dest, destLen, source, sourceLen);
}

int csszlib_compress2 (unsigned char *dest, unsigned long *destLen, const unsigned char *source, unsigned long sourceLen, int level)
{
	return compress2(dest, destLen, source, sourceLen, level);
}
