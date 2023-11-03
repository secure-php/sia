We realized a new plugin `InterpreterMonitor` of S2E to perceive WebPC from PHP engine.
The modification made for PHP is to expose WebPC to S2E's plugin.

## Mark Superglobals
We choose to label superglobal variables as symbolic when they are stored.
In particular, PHP variables are managed using hash tables.
We thus hook the hash stores and accordingly set symbolic variables using `s2e_make_symbolic` API.
```c
// php-src/Zend/zend_hash.c

if(getenv("ENABLE_SYMPHP")){
    
    // if superglobals
    if (ht == Z_ARRVAL(PG(http_globals)[TRACK_VARS_GET]) || 
    ht == Z_ARRVAL(PG(http_globals)[TRACK_VARS_POST])) {
        
        // if not yet symbolic, then make it symbolic
        if(! s2e_is_symbolic(&p->val, sizeof(p->val))) {
            uint32_t sym_name_length = strlen("_SYM_") + strlen(ZSTR_VAL(key)) + 1;
            char *sym_name = (char *)malloc(sym_name_length * sizeof(char));

            if (sym_name != NULL) {
                strcpy(sym_name, "_SYM_");
                strcat(sym_name, ZSTR_VAL(key));
                s2e_make_symbolic(p->val.value.str->val, p->val.value.str->len, sym_name);
                free(sym_name);
            }
        }
    }
}
```

## Expose WebPC
We enhance the Zend VM to invoke S2E InterpreterMonitor plugin to expose WebPC.

```c
// php-src/Zend/zend_monitor.c

cmd.WEBPC= ((uint64_t) opline->lineno) << 32 | opline->opcode;
if (getenv("ENABLE_SYMPHP")){
    // SymPHP: invoke the S2E plugin about WebPC
    s2e_invoke_plugin("InterpreterMonitor", &cmd, sizeof(cmd));
}
```