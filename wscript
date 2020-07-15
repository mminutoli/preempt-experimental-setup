#!/usr/bin/env python


def options(ctx):
    ctx.load('jinja2_templates', tooldir='waftools')

    graph_data_sets = ctx.add_option_group('Graph Data Sets')
    graph_data_sets.add_option('--inputs-dir', default='', action='store')
    graph_data_sets.add_option(
        '--results-dir', default='', action='store')

    ctx.load('jinja2_templates', tooldir='waftools')
    ctx.load('ripples', tooldir='waftools')
    ctx.load('run_r_plot', tooldir='waftools')


def configure(ctx):
    ctx.load('ripples', tooldir='waftools')
    ctx.load('jinja2_templates', tooldir='waftools')
    ctx.load('run_r_plot', tooldir='waftools')

    ctx.env.INPUTS_DIR = ctx.options.inputs_dir
    ctx.env.RESULTS_DIR = ctx.options.results_dir


def build(ctx):
    ctx.recurse('experiments')
    ctx.recurse('plots')
