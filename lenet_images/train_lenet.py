#!/usr/bin/env sh

import yaml
from utils.shell import run_command

# --- CONFIGURE ---

# Read in system-specific configuration values. Edit this config.yaml file before running
config = yaml.load( open('config.yaml').read() )


# --- RUN ---

command = "%s/caffe train --solver=model/lenet_solver.prototxt" % (config['caffe_home'],)
run_command(command)

