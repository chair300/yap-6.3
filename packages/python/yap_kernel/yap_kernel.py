from __future__ import print_function

from ipykernel.ipkernel import IPythonKernel

import sys
import signal
import yap
# import ipdb
# ipdb,set_trace()

kernel_json = {
    "argv": [sys.executable,
             "-m", "yap_kernel",
             "-f", "{connection_file}"],
    "display_name": " YAP-6.3",
    "language": "prolog",
    "name": "yap_kernel",
}


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


class YAPKernel(IPythonKernel):
    implementation = 'YAP Kernel'
    implementation_version = '1.0'
    language = 'text'
    language_version = '0.1'
    banner = "YAP-6.3"
    language_info = {
        'mimetype': 'text/prolog',
        'name': 'text',
        # ------ If different from 'language':
        'codemirror_mode': {
            "version": 2,
            "name": "prolog"
        },
        'pygments_lexer': 'prolog',
        'version': "0.0.1",
        'file_extension': '.yap',
    }

    def init_yap(self, **kwargs):
        # Signal handlers are inherited by
        # forked processes,
        # and we can't easily
        # reset it from the subprocess. Since kernelapp
        # ignores SIGINT except in
        # message handlers, we need to temporarily
        # reset the SIGINT handler
        # here so that yap and its children are interruptible.
        sig = signal.signal(signal.SIGINT, signal.SIG_DFL)
        try:
            self.engine = yap.YAPEngine()
            self.q = None
            self.engine.query("load_files(library(python), [])").command()
            self.engine.query("load_files(library(jupyter), [])").command()
            banner = "YAP6-3 Kernel"
            self.olines = banner
        finally:
            signal.signal(signal.SIGINT, sig)

    def __init__(self, **kwargs):
        super(YAPKernel, self).__init__(**kwargs)
        self.init_yap(**kwargs)
        self.shell.run_cell = self.yap_run_cell

    def get_usage(self):
        return "This is the YAP kernel."

    def yap_run_cell(self, s, store_history=False, silent=False,
                     shell_futures=True):

        if not self.q:
            self.q = self.engine.query(s)
        if self.q.next():
            myvs = self.q.namedVarsCopy()
            if myvs:
                i = 0
                for peq in myvs:
                    name = peq[0]
                    bind = peq[1]
                    if bind.isVar():
                        var = yap.YAPAtom('$VAR')
                        f = yap.YAPFunctor(var, 1)
                        bind.unify(yap.YAPApplTerm(f, (name)))
                    else:
                        i = bind.numberVars(i, True)
                        print(name.text() + " = " + bind.text())
            else:
                print("yes")
            if self.q.deterministic():
                self.closeq()
            return
        print("No (more) answers")
        self.closeq()
        return

    def closeq(self):
        if self.q:
            self.q.close()
            self.q = None
