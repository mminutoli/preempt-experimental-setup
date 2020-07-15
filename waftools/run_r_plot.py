#!/usr/bin/env python
# encoding: utf-8

import os, sys
from waflib import Task, TaskGen, Logs, Node

R_COMMANDS = ['Rscript']

def configure(ctx):
	ctx.find_program(R_COMMANDS, var='RCMD', mandatory=False)
	ctx.env.RFLAGS = '--silent'

class run_r_plot(Task.Task):
	"""Run a R script."""
	run_str = '${RCMD} ${RFLAGS} ${SRC[0].abspath()} -o ${TGT[0].abspath()} ${x for x in tsk.flags} ${x.abspath() for x in tsk.inputs[1:]}'
	shell = False

@TaskGen.feature('run_r_plot')
@TaskGen.before_method('process_source')
def apply_run_r_script(tg):
    src_nodes = [tg.path.find_resource(tg.source)]
    tgt_nodes = [tg.path.find_or_declare(t) for t in tg.to_list(tg.target)]

    for x in tg.to_list(getattr(tg, 'data', [])):
        node = x if isinstance(x, Node.Node) else tg.path.get_src().find_resource(x)
        if not node:
            tg.bld.fatal('Could not find dependency %r for running %r' % (x, src_nodes[0].abspath()))
        src_nodes.append(node)

    tsk = tg.create_task('run_r_plot', src=src_nodes, tgt=tgt_nodes, stdout=None, stderr=None)
    tsk.flags = tg.to_list(getattr(tg, 'flags', []))

	# Bypass the execution of process_source by setting the source to an empty list
    tg.source = []

