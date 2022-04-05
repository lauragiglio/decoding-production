function [] = contrasts_sents(s,task,del)
%clear all
% del = 1 if want to delete previous contrasts, 0 if want to keep them
addpath('/home/common/matlab/spm12/')

%s = 1 %subject number



firstleveldir = ['/project/3011226.02/bids/derivatives/SPM/firstlevel/'];
%s = 1 %subject number
subj = ['sub-0' sprintf('%02d', s)];


spm('defaults','fmri');
spm_jobman('initcfg'); 
%%
matlabbatch{1}.spm.stats.con.spmmat = {[firstleveldir subj '/' task '/SPM.mat']};

load([firstleveldir subj '/' task '/SPM.mat'])

%ix = regexp(SPM.xX.name, regexptranslate('wildcard', strcat("Sn(*) ", names(i), "*bf(1)")));
%find(not(cellfun('isempty',ix)))
%NP_P1 = (strfind(SPM.xX.name, 'Sn(*) wurgen*bf(1)'));

nBetas = size(SPM.Vbeta,2);
sentcount=1;
for r=1:size(SPM.Sess,2) %number runs

    for i=1:50 % max number of sentences per run
        
        sent_sess = find(strcmp(SPM.xX.name, strcat("Sn(",string(r),") ",string(i),"*bf(1)")));
        
        if ~isempty(sent_sess)
        
            matlabbatch{1}.spm.stats.con.consess{sentcount}.tcon.name = 'sent';       
            matlabbatch{1}.spm.stats.con.consess{sentcount}.tcon.weights = zeros(1,nBetas);
            matlabbatch{1}.spm.stats.con.consess{sentcount}.tcon.weights(sent_sess) = 1;
            %matlabbatch{1}.spm.stats.con.consess{i}.tcon.weights(names_idx+1) = 0; % derivative
            matlabbatch{1}.spm.stats.con.consess{sentcount}.tcon.sessrep = 'none';
        
            sentcount = sentcount+1;
        end
    end
end

% for sent=1:48
%     
% matlabbatch{1}.spm.stats.con.consess{sent}.tcon.name = 'sent';
% matlabbatch{1}.spm.stats.con.consess{sent}.tcon.weights = zeros(1,96);
% matlabbatch{1}.spm.stats.con.consess{sent}.tcon.weights((sent*2)-1) = 1;
% matlabbatch{1}.spm.stats.con.consess{sent}.tcon.weights(sent*2) = 1;
% 
% matlabbatch{1}.spm.stats.con.consess{sent}.tcon.sessrep = 'sess';
% 
% end


% for sent=1:48
%     
% matlabbatch{1}.spm.stats.con.consess{sent+48}.fcon.name = 'sent';
% matlabbatch{1}.spm.stats.con.consess{sent+48}.fcon.weights = zeros(2,96);
% matlabbatch{1}.spm.stats.con.consess{sent+48}.fcon.weights(1,(sent*2)-1) = 1;
% matlabbatch{1}.spm.stats.con.consess{sent+48}.fcon.weights(2,sent*2) = 1;
% 
% matlabbatch{1}.spm.stats.con.consess{sent+48}.fcon.sessrep = 'sess';
% 
% end

matlabbatch{1}.spm.stats.con.delete = del;


% run job
spm_jobman('run',matlabbatch);

