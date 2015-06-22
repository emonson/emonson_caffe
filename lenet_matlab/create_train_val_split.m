% Take a directory of ImageNet category directories and do a train / validation split
% and write out train.txt and val.txt that create_database.sh needs

%% --- CONFIGURE ---

% Read in system-specific configuration values. Edit this lenet_config.m file before running
config = lenet_config();

% Make sure original image data directory is really a directory
if ~isdir(config.train_image_data_root)
    fprintf(['Error: train_image_data_root is not a path to a directory: ', config.train_image_data_root', ' \n']);
    fprintf('Set the train_image_data_root variable in config.yaml to the path where the ImageNet training data is stored.\n');
    exit();
end

if ~isfield(config, 'data_split_rand_state')
    fprintf('Warning: data_split_rand_state not in lenet_config.m, so being set to default value of 0\n');
    config.data_split_rand_state = 0;
end

if ~isfield(config, 'validation_fraction')
    fprintf('Warning: validation_fraction not in config.yaml, so being set to default value of 0.2\n');
    config.validation_fraction = 0.2;
end

%% --- RUN ---

fprintf('Reading image names and categories...\n');

% http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
% d = dir(pathFolder);
% isub = [d(:).isdir]; %# returns logical vector
% nameFolds = {d(isub).name}';
% nameFolds(ismember(nameFolds,{'.','..'})) = [];

walk = dir(config.train_image_data_root);
is_dir = [walk(:).isdir];
categories = {walk(is_dir).name}';
categories(ismember(categories,{'.','..','.DS_Store'})) = [];

paths_train = [];
paths_val = [];
cat_dict = {};

% Set random stream seed
s = RandStream('mt19937ar','Seed',config.data_split_rand_state);

% Create list of image paths, with category directory as only prefix
% concatenated with the category index
% and do the train/val split as we go, per category 
for ii = 1:length(categories),
    category = categories{ii};
    category_path = fullfile(config.train_image_data_root, category);
    walk = dir(category_path);
    is_dir = [walk(:).isdir];
    file_list = {walk(~is_dir).name}';
    n_files = length(file_list);
    for ff = 1:n_files,
        % category index 0-based
        file_list{ff} = [fullfile(category, file_list{ff}), ' ', int2str(ii-1)];
    end
    n_val = floor(n_files * config.validation_fraction);
    rand_idxs = randperm(s, n_files);
    paths_train = [paths_train; sort({file_list{rand_idxs(1:end-n_val)}}')];
    paths_val = [paths_val; sort({file_list{rand_idxs(end-n_val+1:end)}}')];
    cat_dict = [cat_dict; {[int2str(ii-1), ' ', category]}];
end

%% Write out text files of file and label integer for both train and validation sets
fprintf('Writing image names and categories...\n');

fid = fopen(fullfile('data','train.txt'), 'w');
for ii = 1:length(paths_train),
    fprintf(fid, '%s\n', paths_train{ii});
end
fclose(fid);

fid = fopen(fullfile('data','val.txt'), 'w');
for ii = 1:length(paths_val),
    fprintf(fid, '%s\n', paths_val{ii});
end
fclose(fid);

fid = fopen(fullfile('data','categories.txt'), 'w');
for ii = 1:length(cat_dict),
    fprintf(fid, '%s\n', cat_dict{ii});
end
fclose(fid);

