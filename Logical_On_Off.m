function [response,start_time]= Logical_On_Off(onset, offset,startsess,endsess,varargin)
%This function takes vectors containing the times of onsets and offsets
%of a signal and creates a continuous logical vector of when the signal is
%on. NOTE, this script may be run in a faster mode that is less robust to
%erroneous consecutive onsets and offsets.

%INPUTS:
%onset - vector of timestamps (in seconds) when the signal turned on(rising edge)
%offset - vector of timestamps (seconds) when the signal turned off (falling edge)

%varargin - %This defines how consecutive onsets and offsets are handled. There
%are currently two modes 'fast', 'robust'
%NOTE, more modes can be added depending on how these
%situations should be handled

%fast - when consecutive onsets or offsets occur, this simply
%ignores all timestamps until the last consecutive event (i.e.
%if there are three onsets in a row, this ignores the first two

%robust - this moves through each event in a for loop and additional
%criteria can be added to handle consecutive onsets and offsets


%OUTPUTS:
%response - logical vector of whether the signal was on or off
%(milliseconds). The length of the vector is determined by the first and
%last timestamps in either vector
%start_time -

%Possible modes:
Consec_Modes = {'fast', 'robust'};

if isempty(varargin)
    
    consec_mode = 'fast';
else
    consec_mode = varargin{1};
    %Check to make sure this mode exists
    if ~any(strcmpi(consec_mode, Consec_Modes))
        disp('The optional input is not a possible mode')
        return
    end
end


% startsess = min([onset; offset]);
% endsess = max([onset; offset]);
%Set the nosepokes to all false (unpoked)
response = false(1, round(1000*(endsess - startsess)));


if (isempty(onset) &&  isempty(offset)) || (numel(onset) == numel(offset) && all(onset == offset))
    return
end

if ~isempty(onset) &&  isempty(offset)
    offset = endsess;
    
elseif isempty(onset) &&  ~isempty(offset)
    onset = startsess;
end

if size(onset,2) > 1
    onset = onset';
end

if size(offset,2) > 1
    offset = offset';
end

while onset(1) > offset(1)
    offset(1) = [];
end

while onset(end) > offset(end)
    onset(end) = [];
end

% if inpoke(end) == endsess
%
%     inpoke(end) = [];
% end

% if outpoke(end) == endsess
%
%     outpoke(end) = [];
% end

if (isempty(onset) &&  isempty(offset))
    return
end

ins = [round(1000*onset) ones(size(onset))];
outs = [round(1000*offset) 2*ones(size(offset))];

allp = sortrows([ins; outs],1);

%This determines which mode to use
switch consec_mode
    
    case 'fast'
        
        remov = true;
        %This loop checks for consecutive onsets or offsets until they're
        %all removed
        while any(remov)
            
            remov = [diff(allp(:,2)) == 0; false];
            
            %remove consecutive rows:
            allp(remov,:) = [];
            
        end
        
        if sum(allp(:,2) == 1) ~= sum(allp(:,2) == 2)
            disp('unequal number of onsets and offsets, need to fix')
        end
        
        start_time = round(1000*(startsess));
        
        for i = 1:2:size(allp,1)
            
            response((allp(i,1)+1:allp(i+1,1)) - start_time) = true;
        end    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'robust'
        %last keeps track of whether the prior time was an off or an on (its
        %defaulted to off)
        last = false;
        last_ind = 1;
        
        start_time = round(1000*(startsess));
        
        %This loop goes through each onset or offset and sets response to
        %true or false based on the prior event. If two onsets occur in a
        %row, the signal is set to on throughout both events.
        inds = allp(:,1) - start_time + 1;
        for i = 1:size(allp,1)
            %if two offsets occur consecutively, ignore the prior offset
            if ~last && allp(i,2) == 2
                last = true;
            end
            
            response(last_ind: inds(i)) = last;
            if i < numel(inds)
                
                last = allp(i,2) == 1;
                last_ind = inds(i);
            else
                
                response(inds(i):end) = allp(i,2) == 1;
            end
        end
end
end
        
        
    
    
