///
/// Copyright (C) 2023, SymPHP
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

#ifndef S2E_PLUGINS_INTERPRETERMONITOR_H
#define S2E_PLUGINS_INTERPRETERMONITOR_H

#include <s2e/Plugin.h>

#include <s2e/Plugins/Core/BaseInstructions.h>


namespace s2e {
namespace plugins {


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



class InterpreterMonitor : public Plugin, public IPluginInvoker {

    S2E_PLUGIN
public:
    InterpreterMonitor(S2E *s2e) : Plugin(s2e) {
    }

    void initialize();
    // Allow the guest to communicate with this plugin using s2e_invoke_plugin
    virtual void handleOpcodeInvocation(S2EExecutionState *state, uint64_t guestDataPtr, uint64_t guestDataSize);


private:
    void onStateFork(S2EExecutionState *originalState, const std::vector<S2EExecutionState *> &newStates,
                                  const std::vector<klee::ref<klee::Expr>> &newConditions);
};

} // namespace plugins
} // namespace s2e

#endif // S2E_PLUGINS_INTERPRETERMONITOR_H
