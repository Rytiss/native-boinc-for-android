// This file is part of BOINC.
// http://boinc.berkeley.edu
// Copyright (C) 2008 University of California
//
// BOINC is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// BOINC is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with BOINC.  If not, see <http://www.gnu.org/licenses/>.

// update_stats:
// Update average credit for idle users, hosts and teams.
// These fields are updates as new credit is granted;
// the purpose of this program is to decay credit of entities
// that are inactive for long periods.
// Hence it should be run about once a day at most.
//
// Also updates the nusers field of teams
//
// usage: update_stats [-update_teams] [-update_users] [-update_hosts]
#include "config.h"
#include <cstdio>
#include <cstring>
#include <string>
#include <cstdlib>
#include <unistd.h>

#include "boinc_db.h"
#include "util.h"
#include "str_util.h"
#include "error_numbers.h"

#include "sched_config.h"
#include "sched_util.h"
#include "sched_msgs.h"

#ifdef EINSTEIN_AT_HOME
#define UPDATE_INTERVAL 3600*24;
#else
#define UPDATE_INTERVAL 3600*24*4;
#endif

double update_time_cutoff;

int update_users() {
    DB_USER user;
    int retval;
    char buf[256];

    while (1) {
        retval = user.enumerate("where expavg_credit>0.1");
        if (retval) {
            if (retval != ERR_DB_NOT_FOUND) {
                log_messages.printf(MSG_CRITICAL, "lost DB conn\n");
                exit(1);
            }
            break;
        }

        if (user.expavg_time > update_time_cutoff) continue;
        update_average(0, 0, CREDIT_HALF_LIFE, user.expavg_credit, user.expavg_time);
        sprintf( buf, "expavg_credit=%f, expavg_time=%f",
            user.expavg_credit, user.expavg_time
        );
        retval = user.update_field(buf);
        if (retval) {
            log_messages.printf(MSG_CRITICAL, "Can't update user %d\n", user.id);
            return retval;
        }
    }

    return 0;
}

int update_hosts() {
    DB_HOST host;
    int retval;
    char buf[256];

    while (1) {
        retval = host.enumerate("where expavg_credit>0.1");
        if (retval) {
            if (retval != ERR_DB_NOT_FOUND) {
                log_messages.printf(MSG_CRITICAL, "lost DB conn\n");
                exit(1);
            }
            break;
        }

        if (host.expavg_time > update_time_cutoff) continue;
        update_average(0, 0, CREDIT_HALF_LIFE, host.expavg_credit, host.expavg_time);
        sprintf(
            buf,"expavg_credit=%f, expavg_time=%f",
            host.expavg_credit, host.expavg_time
        );
        retval = host.update_field(buf);
        if (retval) {
            log_messages.printf(MSG_CRITICAL, "Can't update host %d\n", host.id);
            return retval;
        }
    }

    return 0;
}

int get_team_totals(TEAM& team) {
    int nusers;
    int retval;
    DB_USER user;
    char buf[256];

    // count the number of users on the team
    //
    sprintf(buf, "where teamid=%d", team.id);
    retval = user.count(nusers, buf);
    if (retval) return retval;

    if (team.nusers != nusers) {
        log_messages.printf(MSG_CRITICAL,
            "updating member count for [TEAM#%d]: database has %d users, count shows %d\n",
            team.id, team.nusers, nusers
        );
    }
    team.nusers = nusers;

    return 0;
}

// fill in the nusers, total_credit and expavg_credit fields
// of the team table.
// This may take a while; don't do it often
//
int update_teams() {
    DB_TEAM team;
    int retval;
    char buf[256];

    while (1) {
        retval = team.enumerate("where expavg_credit>0.1");
        if (retval) {
            if (retval != ERR_DB_NOT_FOUND) {
                log_messages.printf(MSG_CRITICAL, "lost DB conn\n");
                exit(1);
            }
            break;
        }

        retval = get_team_totals(team);
        if (retval) {
            log_messages.printf(MSG_CRITICAL,
                "update_teams: get_team_credit([TEAM#%d]) failed: %d\n",
                team.id,
                retval
            );
            continue;
        }
        if (team.expavg_time < update_time_cutoff) {
            update_average(0, 0, CREDIT_HALF_LIFE, team.expavg_credit, team.expavg_time);
        }
        sprintf(
            buf, "expavg_credit=%f, expavg_time=%f, nusers=%d",
            team.expavg_credit, team.expavg_time, team.nusers
        );
        retval = team.update_field(buf);
        if (retval) {
            log_messages.printf(MSG_CRITICAL, "Can't update team %d\n", team.id);
            return retval;
        }
    }
    return 0;
}

int main(int argc, char** argv) {
    int retval, i;
    bool do_update_teams = false, do_update_users = false;
    bool do_update_hosts = false;

    update_time_cutoff = time(0) - UPDATE_INTERVAL;

    check_stop_daemons();

    for (i=1; i<argc; i++) {
        if (!strcmp(argv[i], "-update_teams")) {
            do_update_teams = true;
        } else if (!strcmp(argv[i], "-update_users")) {
            do_update_users = true;
        } else if (!strcmp(argv[i], "-update_hosts")) {
            do_update_hosts = true;
        } else if (!strcmp(argv[i], "-d")) {
            log_messages.set_debug_level(atoi(argv[++i]));
        } else {
            log_messages.printf(MSG_CRITICAL, "Unrecognized arg: %s\n", argv[i]);
        }
    }

    log_messages.printf(MSG_NORMAL, "Starting\n");

    retval = config.parse_file();
    if (retval) {
        log_messages.printf(MSG_CRITICAL,
            "Can't parse config.xml: %s\n", boincerror(retval)
        );
        exit(1);
    }
    retval = boinc_db.open(config.db_name, config.db_host, config.db_user, config.db_passwd);
    if (retval) {
        log_messages.printf(MSG_CRITICAL, "Can't open DB\n");
        exit(1);
    }
    retval = boinc_db.set_isolation_level(READ_UNCOMMITTED);
    if (retval) {
        log_messages.printf(MSG_CRITICAL,
            "boinc_db.set_isolation_level: %d; %s\n", retval, boinc_db.error_string()
        );
    }

    if (do_update_users) {
        retval = update_users();
        if (retval) {
            log_messages.printf(MSG_CRITICAL, "update_users failed: %d\n", retval);
            exit(1);
        }
    }

    if (do_update_hosts) {
        retval = update_hosts();
        if (retval) {
            log_messages.printf(MSG_CRITICAL, "update_hosts failed: %d\n", retval);
            exit(1);
        }
    }

    if (do_update_teams) {
        retval = update_teams();
        if (retval) {
            log_messages.printf(MSG_CRITICAL, "update_teams failed: %d\n", retval);
            exit(1);
        }
    }

    log_messages.printf(MSG_NORMAL, "Finished\n");
    return 0;
}

const char *BOINC_RCSID_6b05e9ecce = "$Id: update_stats.cpp 18042 2009-05-07 13:54:51Z davea $";
