## Training LeNet with a collection of labeled images for classification

This example is designed to train the LeNet example network on a set of images.
They should be pre-processed to square (e.g. 256 x 256 pixels), JPEG encoded, and grayscale.
The `util/` directory contains some sample shell scripts which use the ImageMagick
`convert` program to do this processing. (For example, `util/resize_256_gray.sh`
converts image to 8-bit grayscale, resizes them to 256 pixels on the short side,
and then crops down to 256 x 256 pixels from the center.)

*Short version of running procedure:*

```
# edit config.yaml to set paths to caffe binaries and image sets
./create_train_val_split.py
./make_train_val_database.py
# edit last line of model/lenet_solver.prototxt to set GPU or CPU run
./train_lenet.py
```

*NOTE:*

If you run out of GPU memory, edit `model/lenet_train_test.prototxt` to reduce
the TRAIN layer `batch_size` or make your images smaller.

If the loss value blows up (e.g. 87 or nan, rather than 0.5 or 2), edit
`model/lenet_solver.prototxt` to reduce the learning rate, `base_lr`.


### Image sets directory structure

After processing, the images need to be in a specific directory structure.
The entire set of images should be in a root directory which contains
subdirectories naming the categories (labels) of the images. For example:

```
edges_gray_256/
  cows/
    im_01.jpg
    im_02.jpg
    im_03.jpg
  sailboats/
    im_04.jpg
    im_05.jpg
  windmills/
    im_06.jpg
    im_07.jpg
    im_08.jpg
```


### config.yaml

The scripts to prepare data for and train the networks are written in Python,
partly so that it's easier for them to read in and share a common configuration
`config.yaml` file. This file specifies the path (directory location) of the caffe
binary executables, the image data, and a random seed and test fraction for
the train / validation split on the images. Set appropriate values before running
any of the scripts.

```
caffe_home: /Users/emonson/Programming/caffe/build/tools

train_image_data_root: /Volumes/Data/Not_backed_up/ImageNet/Sets/edges_gray_256
test_image_data_root: /Volumes/Data/Not_backed_up/ImageNet/Sets/edges_gray_256_test

data_split_rand_state: 0
validation_fraction: 0.2
```

### Train / validation split

Two files need to be created which list the names of files and their integer
category labels (space delimited), specifying which images will be used for
training and which for validation. Run the `create_train_val_split.py` script
first to create the `train.txt` and `val.txt` text files in the `data/` directory.


### Create LMDB database

Images can be retrieved much faster if they're in an LMDB database than if they
were in an HDF5 file or were just on disk as JPEGs. So, after the train/val split
has been done, you need to run `make_train_val_database.py` to serialize all the images
into two LMDB databases, which will be placed in directories in the `data\` directory.


### Train the network

Run `train_lenet.py`. See notes in the first section for guidance regarding
memory problems and loss explosion.

I've had some trouble in the past trying to direct the output of `train_lenet.py` to 
a log file, seemingly because of the way I've used subprocess.call() to call the shell
commands. I don't totally understand why this particular variant works and others don't,
but it works well to use the stderr and stdout combiner `2>&1` along with piping to `tee`
to get the output to go to file:

```
./train_lenet.py 2>&1 | tee file.log &
```

which will also send output to the screen. (The ampersand at the end will make the
process run in the background so you can log out and still leave it running.)
If you just want output to go to the file and not the screen at all, use

```
./train_lenet.py > file.log 2>&1 &
```