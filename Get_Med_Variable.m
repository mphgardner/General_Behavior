function [Values] = Get_Med_Variable(Filename,Variable)
%This function outputs the values for a given variable from a Med
%Associates file

%Inputs:
%Filename: string - filename of the Med Associates raw data file
%Variable: string - letter variable to be pulled
%datatype: currently the outputs are double

%Values: double - vector of all values stored for the input Variable in the Med
            %Associates file
            
id = fopen(Filename);
T = textscan(id, '%s');

%find the colons
colons = cellfun(@(x) any(strfind(x,':')),T{1});

%find the variable
Start = strncmp(strcat(Variable,':'),T{1},2);
use = false(size(T{1}));
use(find(Start)+1:end) = true;

%find any lines with a letter included
Alphas = cellfun(@any,isstrprop(T{1},'alpha'));

%find the first variable following the variable of interest and set following values as false 
use(find(use & Alphas,1):end) = false;

%remove any entries with colons
use = use & ~colons;

Values = cellfun(@(x) str2double(x),T{1}(use));

fclose(id);
end