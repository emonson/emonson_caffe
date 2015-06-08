#!/usr/bin/env python

import yaml
from utils.shell import run_command

# --- CONFIGURE ---

# Read in system-specific configuration values. Edit this config.yaml file before running
config = yaml.load( open('config.yaml').read() )

command_template = """
%s/caffe.bin test \
    -model=model/lenet_test.prototxt \
    -weights=%s \
    -iterations=%s \
    %s
"""

test_mode = ""
if 'test_mode' in config and config['test_mode'] == 'GPU':
    test_mode = "-gpu 0"

# --- RUN ---

command = command_template % (config['caffe_home'], config['test_model_weights'], config['test_iterations'], test_mode)
run_command(command)

