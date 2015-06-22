% Create the image data lmdb input database for training and validation
% ** NOTE: LeNet needs grayscale images!

% --- CONFIGURE ---

% Read in system-specific configuration values. Edit this lenet_config.m file before running
config = lenet_config();

% convert_imageset will error out if databases already exist, so check and give the option to delete
train_db_exists = isdir('data/lenet_train_lmdb');
val_db_exists = isdir('data/lenet_val_lmdb');
if (train_db_exists || val_db_exists),
    fprintf('WARNING: It looks like the databases already exist!\n');
    del_db = input('Do you want to delete the existing DBs and continue? [y/N]: ');
    if isempty(del_db) || ~strcmpi(del_db, 'y'),
        return;
    else
        if train_db_exists,
            rmdir('data/lenet_train_lmdb','s');
        end
        if val_db_exists,
            rmdir('data/lenet_val_lmdb','s');
        end
    end
end
        
% Make sure original image data directory is really a directory
if ~isdir(config.train_image_data_root)
    fprintf(['Error: train_image_data_root is not a path to a directory: ', config.train_image_data_root', ' \n']);
    fprintf('Set the train_image_data_root variable in config.yaml to the path where the ImageNet training data is stored.\n');
    return;
end


% Make sure train and validation split text files exist,
% otherwise the databases will get created, just with zero images
if ~exist('data/train.txt','file') || ~exist('data/val.txt','file'),
    fprintf('Error: Training and/or validation files, data/train.txt and data/val.txt do not exist\n');
    fprintf('Run create_train_val_split.py before trying to create database!');
    return;
end

% Create a template string for the shell command to feed values into
% Note: Data directory path string needs a slash after it, so we're adding it here explicitly
command_template = [...
'GLOG_logtostderr=1 %s/convert_imageset.bin '...
    '--resize_height=0 '...
    '--resize_width=0 '...
    '--shuffle '...
    '%s/ '...
    'data/%s '...
    'data/lenet_%s_lmdb'...
];


% --- RUN ---

% Add caffe bin directory to PATH
% setenv('PATH', [getenv('PATH') ':' config.caffe_home]);
% setenv('DYLD_LIBRARY_PATH', ['/Users/emonson/anaconda/lib:/usr/local/lib:/usr/lib' getenv('DYLD_LIBRARY_PATH')]);
setenv('DYLD_LIBRARY_PATH', ['/Users/emonson/anaconda/lib:/usr/local/lib:/usr/lib']);

fprintf('Creating train lmdb...\n');
command = sprintf(command_template, config.caffe_home, config.train_image_data_root, 'train.txt', 'train');
[status,cmdout] = system(command, '-echo');

fprintf('Creating val lmdb...\n');
command = sprintf(command_template, config.caffe_home, config.train_image_data_root, 'val.txt', 'val');
[status,cmdout] = system(command, '-echo');

