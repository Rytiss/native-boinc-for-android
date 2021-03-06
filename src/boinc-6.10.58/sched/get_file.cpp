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

// get_file [-host_id host_id] [-file_name file_name]
// -host_id            name of host to upload from
// -file_name          name of specific file, dominates workunit
//
// Create a result entries, initialized to sent, and corresponding
// messages to the host that is assumed to have the file.
//
// Run from the project root dir.

#include "config.h"

#if HAVE_UNISTD_H
#include <unistd.h>
#endif
#include <stdlib.h>
#include <string>
#include <time.h>

#include "boinc_db.h"
#include "util.h"
#include "str_util.h"

#include "sched_config.h"
#include "sched_util.h"
#include "md5_file.h"

void init_xfer_result(DB_RESULT& result) {
    result.id = 0;
    result.create_time = time(0);
    result.workunitid = 0;
    result.server_state = RESULT_SERVER_STATE_IN_PROGRESS;
    result.hostid = 0;
    result.report_deadline = 0;
    result.sent_time = 0;
    result.received_time = 0;
    result.client_state = 0;
    result.cpu_time = 0;
    strcpy(result.xml_doc_out, "");
    strcpy(result.stderr_out, "");
    result.outcome = RESULT_OUTCOME_INIT;
    result.file_delete_state = ASSIMILATE_DONE;
    result.validate_state = VALIDATE_STATE_NO_CHECK;
    result.claimed_credit = 0;
    result.granted_credit = 0;
    result.appid = 0;
}

int create_upload_result(DB_RESULT& result, int host_id, const char * file_name) {
    int retval;
    char result_xml[BLOB_SIZE];
    sprintf(result_xml,
        "<result>\n"
        "    <wu_name>%s</wu_name>\n"
        "    <name>%s</wu_name>\n"
        "    <file_ref>\n"
        "      <file_name>%s</file_name>\n"
        "    </file_ref>\n"
        "</result>\n",
        result.name, result.name, file_name
    );
    strcpy(result.xml_doc_in, result_xml);
    result.sent_time = time(0);
    result.report_deadline = 0;
    result.hostid = host_id;
    retval = result.insert();
    if (retval) {
        fprintf(stderr, "result.insert(): %d\n", retval);
        return retval;
    }
    return 0;
}

int create_upload_message(DB_RESULT& result, int host_id, const char* file_name) {;
    DB_MSG_TO_HOST mth;
    int retval;
    mth.clear();
    mth.create_time = time(0);
    mth.hostid = host_id;
    strcpy(mth.variety, "file_xfer");
    mth.handled = false;
    sprintf(mth.xml,
        "<app>\n"
        "    <name>%s</name>\n"
        "</app>\n"
        "<app_version>\n"
        "    <app_name>%s</app_name>\n"
        "    <version_num>%d00</version_num>\n"
        "</app_version>\n"
        "<file_info>\n"
        "    <name>%s</name>\n"
        "    <url>%s</url>\n"
        "    <max_nbytes>%.0f</max_nbytes>\n"
        "    <upload_when_present/>\n"
        "</file_info>\n"
        "%s"
        "<workunit>\n"
        "    <name>%s</name>\n"
        "    <app_name>%s</app_name>\n"
        "</workunit>",
        FILE_MOVER, FILE_MOVER, BOINC_MAJOR_VERSION,
        file_name, config.upload_url,
        1e10, result.xml_doc_in, result.name, FILE_MOVER
    );
    retval = mth.insert();
    if (retval) {
        fprintf(stderr, "msg_to_host.insert(): %d\n", retval);
        return retval;
    }
    return 0;
}

int get_file(int host_id, const char* file_name) {
    DB_RESULT result;
    long int my_time = time(0);
    int retval;
    result.clear();
    init_xfer_result(result);
    sprintf(result.name, "get_%s_%d_%ld", file_name, host_id, my_time);
    result.hostid = host_id;
    retval = create_upload_result(result, host_id, file_name);
    retval = create_upload_message(result, host_id, file_name);
    return retval;
}


int main(int argc, char** argv) {
    int i, retval;
    char file_name[256];
    int host_id;

    strcpy(file_name, "");
    host_id = 0;

    check_stop_daemons();

    for(i=1; i<argc; i++) {
        if (!strcmp(argv[i], "-host_id")) {
            host_id = atoi(argv[++i]);
        } else if (!strcmp(argv[i], "-file_name")) {
            strcpy(file_name, argv[++i]);
        } else if (!strcmp(argv[i], "-help")) {
            fprintf(stdout,
                "get_file: gets a file to a specific host\n\n"
                "It takes the following arguments and types:\n"
                "-hostid (int); the number of the host\n"
                "-file_name (string); the name of the file to get\n"
            );
            exit(0);
        } else {
            if (!strncmp("-",argv[i],1)) {
                fprintf(stderr, "get_file: bad argument '%s'\n", argv[i]);
                fprintf(stderr, "type get_file -help for more information\n");
                exit(1);
            }
        }
    }

    if (!strlen(file_name) || host_id == 0) {
        fprintf(stderr,
            "get_file: bad command line, requires a valid host_id and file_name\n"
        );
        exit(1);
    }

    retval = config.parse_file();
    if (retval) {
        fprintf(stderr, "Can't parse config.xml: %s\n", boincerror(retval));
        exit(1);
    }

    retval = boinc_db.open(
        config.db_name, config.db_host, config.db_user, config.db_passwd
    );
    if (retval) {
        fprintf(stderr, "boinc_db.open failed: %d\n", retval);
        exit(1);
    }

    retval = get_file(host_id, file_name);
    boinc_db.close();
    return retval;
}

const char *BOINC_RCSID_37238a0141 = "$Id: get_file.cpp 18042 2009-05-07 13:54:51Z davea $";
