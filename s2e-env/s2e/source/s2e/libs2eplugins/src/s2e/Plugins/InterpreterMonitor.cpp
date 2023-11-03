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

#include <s2e/S2E.h>
#include <s2e/ConfigFile.h>

#include "InterpreterMonitor.h"
using namespace klee;
namespace s2e {
namespace plugins {

namespace {

//
// This class can optionally be used to store per-state plugin data.
//
// Use it as follows:
// void InterpreterMonitor::onEvent(S2EExecutionState *state, ...) {
//     DECLARE_PLUGINSTATE(InterpreterMonitorState, state);
//     plgState->...
// }
//
}
S2E_DEFINE_PLUGIN(InterpreterMonitor, "Monitor PHP interpreter to obtain WEBPC", "", );

void InterpreterMonitor::initialize() {
    //s2e()->getCorePlugin()->onStateFork.connect(sigc::mem_fun(*this, &InterpreterMonitor::onStateFork));
}



void InterpreterMonitor::handleOpcodeInvocation(S2EExecutionState *state, uint64_t guestDataPtr, uint64_t guestDataSize)
{
    S2E_INTERPRETERMONITOR_COMMAND command;

    if (guestDataSize != sizeof(command)) {
        getWarningsStream(state) << "mismatched S2E_INTERPRETERMONITOR_COMMAND size\n";
        return;
    }

    if (!state->mem()->read(guestDataPtr, &command, guestDataSize)) {
        getWarningsStream(state) << "could not read transmitted data\n";
        return;
    }
    // force type conversion.
    switch (command.Command) {
        // TODO: add custom commands here
        case PHP_WEBPC:
            // how to get parameters?
            // DECLARE_PLUGINSTATE(InterpreterMonitorState, state);
            state->setWEBPC(command.WEBPC);
            s2e()->getDebugStream() << "InterpreterMonitor::handleopcode set:" << state->getID() << " : "  << hexval(command.WEBPC) << " : "<< hexval(state->getWEBPC()) << '\n';
            break;
    }
}

void InterpreterMonitor::onStateFork(S2EExecutionState *originalState, const std::vector<S2EExecutionState *> &newStates,
                                  const std::vector<klee::ref<klee::Expr>> &newConditions) {
	/*
     We only need to pass through the WEBPC id from orignialState to newStates.
    */

    // This macro declares the plgState variable of type InstructionTrackerState.
    // It automatically takes care of retrieving the right plugin state attached to the specified execution state
    // DECLARE_PLUGINSTATE(InterpreterMonitorState, originalState);
    // uint64_t tmp = plgState->get();
    uint64_t tmp = originalState->getWEBPC();
    s2e()->getDebugStream() << "InterpreterMonitor::onStateFork before " << originalState->getID() <<  " : " << hexval(tmp) << '\n';
    for (unsigned i = 0; i < newStates.size(); i++) {
        //DECLARE_PLUGINSTATE(InterpreterMonitorState, newStates[i]);
        //plgState->set(tmp);
        s2e()->getDebugStream() << "InterpreterMonitor::onStateFork newstate " << newStates[i]->getID() << " : " << hexval(newStates[i]->getWEBPC()) << '\n';
        newStates[i]->setWEBPC(tmp);
    }

}

} // namespace plugins
} // namespace s2e
