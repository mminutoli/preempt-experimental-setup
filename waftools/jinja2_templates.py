#!/usr/bin/env python


from waflib.TaskGen import extension
from waflib import Task


class jinja_generate(Task.Task):
    def keyword(self):
        return 'Generating'

    def __str__(self):
        return self.outputs[0].relpath()

    def run(self):
        from jinja2 import Template
        template = Template(self.inputs[0].read())
        self.outputs[0].write(template.render(self.args))
        return 0


@extension('.jinja2')
def jinja(self, node):
    from jinja2 import Environment, meta

    self.name # This is a mistery, but it makes the framework
              # find the task generator by name.
    self.source = self.to_nodes(getattr(self, 'source'))

    env = Environment()
    parsed_content = env.parse(self.source[0].read())
    variables = meta.find_undeclared_variables(parsed_content)

    args = {v: getattr(self, v) for v in variables}

    if isinstance(self.target, str):
        self.target = self.target.split()
    if not isinstance(self.target, list):
        self.target = [self.target]

    if isinstance(self.target[0], str):
        tmp = self.path.find_or_declare(self.target[0])
    else:
        tmp = self.target[0]
        tmp.mkdir()

    self.target = [tmp]
    tsk = self.create_task('jinja_generate', node, tmp)
    tsk.args = args
    try:
        self.generative_task.append(tsk)
    except AttributeError:
        self.generative_task = [tsk]
    return tsk


def options(ctx):
    ctx.load('python')


def configure(ctx):
    ctx.load('python')
    ctx.check_python_version((3, 5, 0))
    ctx.check_python_module('jinja2')
