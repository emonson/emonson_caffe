#!/usr/bin/env sh

caffe_home=/Users/emonson/Programming/caffe/build/tools

$caffe_home/caffe train --solver=model/lenet_solver.prototxt
