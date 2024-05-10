function [DAT] = Get_Med_Variable(Filename,Variable)
%This function outputs the values for a set of variable from a Med
%Associates file
%This file was modified to import multiple sessions in the same med file

%Inputs:
%Filename: string - filename of the Med Associates raw data file
%Variable: string or cell - letter variable to be pulled; if multiple, put
%each variable as a string in a cell array
%datatype: currently the outputs are double

%Outputs
%Output is a structure with header information and variable information as
%fields
%string variable fields: double - vector of all values stored for the input
%Variable in the Med Associates file

id = fopen(Filename);

%Import all lines from the file. First check whether there are multiple
%sessions stored within the same file.
T = textscan(id, '%s','delimiter','\t');

%This assumes that each session has header Start Date
session_starts = strncmp('Start Date',T{1},10);
sessions = sum(session_starts);

fclose(id)
id = fopen(Filename);

%Check whether the Variable input is a cell array
if iscell(Variable)
    n_var = numel(Variable);
    Var = Variable;
else
    n_var = 1;
    Var{1} = Variable;

end



%Code for 1 session
if sessions == 1

    %To import the summary variables or headers first import with tab
    %delimiters: Change number of rows if format for MED changes, currently its
    %the fist 10 rows are headers
    Headers = textscan(id, '%s', 10,'delimiter','\t');

    %This gets the header info
    I = cellfun(@(x) x(strfind(x,':')+2:end),Headers{1},'UniformOutput',false);

    %I{1} is the filename:
    DAT.Filename = I{1};
    DAT.Date = I{2};
    DAT.Subject = str2double(I{4});
    DAT.Experiment = I{5};
    DAT.Group = I{6};
    DAT.Box = I{7};
    DAT.Start_Time = I{8};
    DAT.Protocol = I{10};


    %Import the data
    T = textscan(id, '%s');
    %All data is put in the first cell of T, set T to just the first cell
    T = T{1};

    %find the colons
    colons = cellfun(@(x) any(strfind(x,':')),T);


    %find any lines with a letter included
    Alphas = cellfun(@any,isstrprop(T,'alpha'));

    for i = 1:n_var

        %find the variable
        Start = strncmp(strcat(Var{i},':'),T,2);
        use = false(size(T));
        use(find(Start)+1:end) = true;

        %find the first variable following the variable of interest and set following values as false
        use(find(use & Alphas,1):end) = false;

        %remove any entries with colons
        use = use & ~colons;

        DAT.(Var{i}) = cellfun(@(x) str2double(x),T(use));
    end

    fclose(id);

%More than one session
else
   
   %Get rid of the superflous cell array
   T = T{1};

   %Import the data as separate strings. MATLAB does not treat the tabs
   %within the Med matricies as tabs, so they must be imported as separate
   %strings
   %The T cell array will be used to read the headers
   sess_starts_T = find(session_starts);
   
   %The D cell array will be used to grab the data
   D = textscan(id, '%s'); 
   D = D{1};
   %MSN is a unique identifier for the headers 
   sess_starts_D = find(strcmp('MSN:',D));
   
   %set the end of sess_starts to the end of the session
   sess_starts_D(end + 1) = numel(D);

   %Variables always have the variable letter followed by a colon
   %Find colons in the second position
   %colons = strncmp(T,':',2);
    
   %find the colons
   colons = cellfun(@(x) any(strfind(x,':')),D);


    %find any lines with a letter included. This is needed as some colons
    %in the second value of the string is for the array data
    Alphas = cellfun(@any,isstrprop(D,'alpha'));

   filename = T{1};

   for s = 1:sessions
        
        Headers = T(sess_starts_T(s):sess_starts_T(s)+8);


        %This gets the header info
        I = cellfun(@(x) x(strfind(x,':')+2:end),Headers,'UniformOutput',false);

        %I{1} is the filename:
        DAT(s).Filename = filename;
        DAT(s).Date = I{1};
        DAT(s).Subject = I{3};
        DAT(s).Experiment = I{4};
        DAT(s).Group = I{5};
        DAT(s).Box = I{6};
        DAT(s).Start_Time = I{7};
        DAT(s).End_Time = I{8};
        DAT(s).Protocol = I{9};


        for i = 1:n_var
    
            %find the variable
            sess_range = sess_starts_D(s):sess_starts_D(s+1);
            Di = D(sess_range);
            Start = strncmp(strcat(Var{i},':'),Di,2);
            use = false(numel(sess_range),1);
            use(find(Start)+1:end) = true;
    
            %find the first variable following the variable of interest and set following values as false
            use(find(use & Alphas(sess_range),1):end) = false;
    
            %remove any entries with colons
            use = use & ~colons(sess_range);
    
            DAT(s).(Var{i}) = cellfun(@(x) str2double(x),Di(use));
        end
   end

   fclose(id);



end


end