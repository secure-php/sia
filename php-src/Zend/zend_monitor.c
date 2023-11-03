#include "../Zend/zend_compile.h"
#include "zend.h"
#include "zend_modules.h"

#include <unistd.h>
#include <string.h>     /* For the real memset prototype.  */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <s2e/s2e.h>

typedef enum S2E_INTERPRETERMONITOR_COMMANDS {
    // TODO: customize list of commands here
    PHP_WEBPC
} S2E_INTERPRETERMONITOR_COMMANDS;

typedef struct S2E_INTERPRETERMONITOR_COMMAND {
    S2E_INTERPRETERMONITOR_COMMANDS Command;
    union {
        // Command parameters go here
        uint64_t WEBPC;
    };
} S2E_INTERPRETERMONITOR_COMMAND;

#define MAPSIZE 65536
// static bitmap[MAPSIZE];
static unsigned char *bitmap= NULL;
static int last = 0;
static int op = 0;
static char* showmap_log = NULL;
static FILE *tout_fp = NULL;


void symphp_trace_opcode(zend_execute_data *execute_data, const zend_op *opline){

    S2E_INTERPRETERMONITOR_COMMAND cmd;
    cmd.Command = PHP_WEBPC;
    // In the paper, we stated we used 32 bits in total but we now changed to use 64 bits.
    cmd.WEBPC= ((uint64_t) opline->lineno) << 32 | opline->opcode;
    
    if (getenv("ENABLE_SYMPHP")){
        // SymPHP: invoke the S2E plugin about WebPC
        s2e_invoke_plugin("InterpreterMonitor", &cmd, sizeof(cmd));
    }

    if (getenv("SYMPHP_DEBUG")) {
        op = (opline->lineno << 8) | opline->opcode ;
        //fprintf(tout_fp, "%d] %s (%d)   %d    %d \n",opline->lineno, opname, opline->opcode, opline->op1_type, opline->op2_type);
        if (last != 0) {
            int bitmapLoc = (op ^ last) % MAPSIZE;
            bitmap[bitmapLoc]++;
        }
        last = (op >> 1);
    }
}


/* 
 * called before analysis
 */
void symphp_trace_init() {
    if (getenv("SYMPHP_DEBUG")) {
        showmap_log = getenv("SYMPHP_DEBUG");
        bitmap = malloc(MAPSIZE);
        memset(bitmap, 0, MAPSIZE);
        op = last = 0;
        tout_fp = fopen(showmap_log, "w");
    }
}

/*
 * called at the end of analysis
 */
void symphp_trace_finish() {
    if (getenv("SYMPHP_DEBUG")) {
        setbuf(tout_fp, NULL);
        int cnt = 0;

        for (int x=0; x < MAPSIZE;x++){
            if (bitmap[x] > 0){
                fprintf(tout_fp, "%d:%d\n", x, bitmap[x]);
                cnt ++;
            }
        }
    }
}
