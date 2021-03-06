/* Copyright 2010 Matthew Arsenault, Travis Desell, Boleslaw
Szymanski, Heidi Newberg, Carlos Varela, Malik Magdon-Ismail and
Rensselaer Polytechnic Institute.

This file is part of Milkway@Home.

Milkyway@Home is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Milkyway@Home is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Milkyway@Home.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _SEPARATION_UTILS_H_
#define _SEPARATION_UTILS_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "separation_types.h"

typedef struct
{
    int q;
    real nstars;
    real sprob;
    real psg;
    real epsilon_s;
} StreamStats;

mwvector transform_point(const AstronomyParameters* ap,
                         mwvector point,
                         const mwmatrix cmat,
                         mwvector xsun);

void get_transform(mwmatrix mat, const mwvector f, const mwvector t);
int prob_ok(StreamStats* ss, int n);
void prob_ok_init(uint32_t seed, int setSeed);

SeparationResults* newSeparationResults(unsigned int numberStreams);
void freeSeparationResults(SeparationResults* p);
int checkSeparationResults(const SeparationResults* results, unsigned int numberStreams);

#ifdef __cplusplus
}
#endif

#endif /* _SEPARATION_UTILS_H_ */

