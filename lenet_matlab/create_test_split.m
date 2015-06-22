% Take a directory of ImageNet category directories and do a train / validation split
% and write out train.txt and val.txt that create_database.sh needs

%% --- CONFIGURE ---

% Read in system-specific configuration values. Edit this lenet_config.m file before running
config = lenet_config();

% Make sure original image data directory is really a directory
if ~isdir(config.train_image_data_root)
    fprintf(['Error: train_image_data_root is not a path to a directory: ', config.test_image_data_root', ' \n']);
    fprintf('Set the train_image_data_root variable in config.yaml to the path where the ImageNet training data is stored.\n');
    exit();
end

%% --- RUN ---

fprintf('Reading image names and categories...\n');

walk = dir(config.train_image_data_root);
is_dir = [walk(:).isdir];
categories = {walk(is_dir).name}';
categories(ismember(categories,{'.','..','.DS_Store'})) = [];

paths_test = [];
cat_dict = {};

% Create list of image paths, with category directory as only prefix
% concatenated with the category index
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
    paths_test = [paths_test; sort(file_list)];
    cat_dict = [cat_dict; {[int2str(ii-1), ' ', category]}];
end

%% Write out text files of file and label integer for both train and validation sets
fprintf('Writing image names and categories...\n');

fid = fopen(fullfile('data','test.txt'), 'w');
for ii = 1:length(paths_test),
    fprintf(fid, '%s\n', paths_test{ii});
end
fclose(fid);

fid = fopen(fullfile('data','test_categories.txt'), 'w');
for ii = 1:length(cat_dict),
    fprintf(fid, '%s\n', cat_dict{ii});
end
fclose(fid);

