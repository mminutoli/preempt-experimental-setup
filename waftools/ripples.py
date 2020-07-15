#!/usr/bin/env python


def options(ctx):
    g = ctx.add_option_group('Ripples')
    g.add_option('--ripples-dir', default='', action='store',
                 help='The directory where ripples tools are installed')

def configure(ctx):
    ripples_dir = ctx.options.ripples_dir

    ctx.find_program('mpi-imm', path_list=ripples_dir, mandatory=False)
    ctx.find_program('imm', path_list=ripples_dir, mandatory=False)
    ctx.find_program('hill-climbing', path_list=ripples_dir, mandatory=False)
    ctx.find_program('mpi-hill-climbing', path_list=ripples_dir, mandatory=False)
    ctx.find_program('dump-graph', path_list=ripples_dir, mandatory=False)
