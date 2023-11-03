#ifndef ZEND_MONITOR_H
#define ZEND_MONITOR_H

#include "zend_compile.h"
#include "zend.h"


extern void symphp_trace_init(void);
extern void symphp_trace_finish(void);
extern void symphp_trace_opcode(zend_execute_data *execute_data, const zend_op *opline);

#define VM_TRACE(op) symphp_trace_opcode(execute_data, opline);
#define VM_TRACE_START() symphp_trace_init();
#define VM_TRACE_END() symphp_trace_finish();


#endif /* ZEND_MONITOR_H*/
