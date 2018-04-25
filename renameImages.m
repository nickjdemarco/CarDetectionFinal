clear;
clc;
close all; 

projectdir = 'E:\Demo Images/';
dinfo = dir( fullfile(projectdir, '*.jpg') );
oldnames = {dinfo.name};

for K = 1 : length(oldnames)
      newName = sprintf('%d.jpg', K);
      movefile( fullfile(projectdir, oldnames{K}), fullfile('Dataset/', newName) );
end