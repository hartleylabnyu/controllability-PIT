
function data = convertDataStruct_me_regression(filepath)
%% Hillary Raab
% 02.11.21

%%%%%%%%%%%%%%%%%%
% input:
    %filepath: path where data from ConPit lives
% output
    %data: a struct that formats data for fit_models.m code
%%%%%%%%%%%%%%%%%%

 file = dir(filepath);
    
    sub = 1;
    data = [];

    
  for n_file = 1:length(file)
    if strcmp(file(n_file).name, '.') || strcmp(file(n_file).name, '..') || strcmp(file(n_file).name, 'Excluded') || strcmp(file(n_file).name, '.DS_Store')
        % Skip if the filename is '.', '..', or 'Excluded'
    else
        C = strsplit(file(n_file).name, '_');
        numericPart = regexp(C{1}, '\d+', 'match');  % Extract numeric part
        studyIDAll(sub) = str2double(numericPart{1});
        sub = sub + 1;

    end
end


    for sub = 1:length(studyIDAll)
        %load participant data
        load([filepath, num2str(studyIDAll(sub)),'ConPit/',num2str(studyIDAll(sub)),'_TaskDataLearning_Session1.mat'])

        %remove where responded early
        TaskDataLearning(TaskDataLearning(:,11)==5 | TaskDataLearning(:,11)==3 ,:) = [];

        %set up structure for mixed-effects regression

        %studyID; trial number; action: nogo is 1 and go is 2; trial type: 1 is GW, 2 is
        %GAL, 3 is NGW, 4 is NGAL; condition: 5050 is uncontrollable, 8020 is controllable
        single_sub = [ones(length(TaskDataLearning),1)*studyIDAll(sub), TaskDataLearning(:,1), TaskDataLearning(:,11)+1, TaskDataLearning(:,2), TaskDataLearning(:,18)];
        data = [data;single_sub];

%         %order: uncontrollable first is 1, controllable first is 2
%         if TaskDataLearning(1,18) == 5050
%             data(sub).cond = ones([data(sub).N,1]);
%             order = 1;
%         elseif TaskDataLearning(1,18) == 8020
%             data(sub).cond =ones([data(sub).N,1]) * 2;
%             order = 2;
%         end
        
        clear TaskDataLearning single_sub
    end
end