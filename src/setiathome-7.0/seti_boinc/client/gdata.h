// Copyright 2003 Regents of the University of California

// SETI_BOINC is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2, or (at your option) any later
// version.

// SETI_BOINC is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.

// You should have received a copy of the GNU General Public License along
// with SETI_BOINC; see the file COPYING.  If not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

// In addition, as a special exception, the Regents of the University of
// California give permission to link the code of this program with libraries
// that provide specific optimized fast Fourier transform (FFT) functions and
// distribute a linked executable.  You must obey the GNU General Public 
// License in all respects for all of the code used other than the FFT library
// itself.  Any modification required to support these libraries must be
// distributed in source code form.  If you modify this file, you may extend 
// this exception to your version of the file, but you are not obligated to 
// do so. If you do not wish to do so, delete this exception statement from 
// your version.

// $Id: gdata.h,v 1.16.2.5 2007/05/31 22:03:10 korpela Exp $

// GDATA is a collection of information generated by the worker thread
// that might be useful for graphics.
// It does not contain any user preference info,
// or anything related to a particular style of graphics.

#ifndef _GDATA_
#define _GDATA_

#include "sah_version.h"
#include "reduce.h"
#ifndef AP_CLIENT
#include "analyze.h"
#include <cstring>

struct GAUSS_INFO;
struct SPIKE_INFO;
struct AUTOCORR_INFO;
struct TRIPLET_INFO;
struct PULSE_INFO;

// Power of time array sizes for graphics routines only.
#define GAUSS_POT_LEN   64
#define PULSE_POT_LEN   256
#define TRIPLET_POT_LEN 256

struct FFT_INFO {
  double chirp_rate;
  int fft_len;
};


struct G_AUTOCORR_INFO {
    void copy(AUTOCORR_INFO *, bool is_best=false);
};

struct G_SPIKE_INFO {
    void copy(SPIKE_INFO *, bool is_best=false);
};

struct G_GAUSS_INFO {
    double score;
    bool is_best;   // true if best score so far
    bool dirty;     // true if we haven't displayed this yet
    double peak_power;
    double mean_power;
    double chisqr;
    double sigma;
    int fft_ind;		// assigned in ReportGaussEvent()
    float pot[GAUSS_POT_LEN];
    void copy(GAUSS_INFO *, bool is_best=false);
	G_GAUSS_INFO() : score(0), is_best(false), dirty(false), peak_power(0), mean_power(0), chisqr(0), sigma(0), fft_ind(0) 
		{ memset(pot,0,sizeof(pot)); };
};

struct G_TRIPLET_INFO {
    double peak_power;
    double period;
    bool is_best;
    bool dirty;
    int tpotind0_0;	// index into pot_min/pot_max arrays
    int tpotind0_1;	// of start/end of first element of triplet
    int tpotind1_0;	// second element
    int tpotind1_1;
    int tpotind2_0;	// and third element
    int tpotind2_1;
    unsigned int pot_min[TRIPLET_POT_LEN];  // Scaled 0-255 for display
    unsigned int pot_max[TRIPLET_POT_LEN];  // Scaled 0-255 for display
    void copy(TRIPLET_INFO *, bool is_best=false);
	G_TRIPLET_INFO() : peak_power(0), period(0), is_best(false), dirty(false), tpotind0_0(0), tpotind0_1(0),
		tpotind1_0(0), tpotind1_1(0), tpotind2_0(0), tpotind2_1(0)
		{ memset(pot_min,0,sizeof(pot_min)); memset(pot_max,0,sizeof(pot_max)); }
};

struct G_PULSE_INFO {
    bool is_best;
    bool dirty;
    double peak_power;
    double period;
    double score;
    unsigned int pot_max[PULSE_POT_LEN];  // Scaled 0-255 for display
    void copy(PULSE_INFO *, bool is_best=false);
	G_PULSE_INFO() : is_best(false), dirty(false), peak_power(0), period(0), score(0)
		{ memset(pot_max,0,sizeof(pot_max)); }
};

#endif

struct G_SETI_WU_INFO {
    char receiver_name[255];
    int s4_id;
    double time_recorded;
    double subband_base;
    double start_ra, start_dec;
    double subband_sample_rate;
};

struct GDATA {
    int ready;
    int version_major;
    int version_minor;
    double local_progress;
    double progress;
    double cpu_time;
    volatile int countdown;
        // the graphics app sets this to 5 every second,
        // and the main app decrements it every second.
        // So if it's zero, it means no graphics app is running
    char status[80];

#ifndef AP_CLIENT
    G_SETI_WU_INFO wu;
    FFT_INFO fft_info;
    G_SPIKE_INFO si;
    G_AUTOCORR_INFO ai;
    G_GAUSS_INFO gi;
    G_TRIPLET_INFO ti;
    G_PULSE_INFO pi;
#endif
};

// SAH_SHMEM is the shared-memory structure

struct SAH_SHMEM {
    GDATA gdata;
    REDUCED_ARRAY_DATA rarray_data;
};

#endif
