% Copyright and terms of use (DO NOT REMOVE):
% The code is made freely available for non-commercial uses only, provided that the copyright 
% header in each file is not removed, and suitable citation(s) (see below) are made for papers 
% published based on the code.
%
% The code is not optimized for speed, and we are not responsible for any errors that might
% occur in the code.
%
% The copyright of the code is retained by the authors.  By downloading/using this code you
% agree to all the terms stated above.
%
% Hamdi Yahyaoui, Hosam AboElfotoh and Yanjun Shu 
% A Multilevel Adaptive Reduction Technique for Time Series (MART), Research Grant No. [SU02/20],
% Computer Science Department, Kuwait University.



% knnclassify matlab function updated by adding the new CP Distance
function outClass = knnclassify_Mod(sample, TRAIN, group, K, distance,rule)
%bioinfochecknargin(nargin,3,mfilename)
% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups] = grp2idx(group);
nans = find(isnan(gindex));
if ~isempty(nans)
    TRAIN(nans,:) = [];
    gindex(nans) = [];
end
ngroups = length(groups);

[n,d] = size(TRAIN);
if size(gindex,1) ~= n
    error(message('bioinfo:knnclassify:BadGroupLength'));
elseif size(sample,2) ~= d
    error(message('bioinfo:knnclassify:SampleTrainingSizeMismatch'));
end
m = size(sample,1);

if nargin < 4
    K = 1;
elseif ~isnumeric(K)
    error(message('bioinfo:knnclassify:KNotNumeric'));
end
if ~isscalar(K)
    error(message('bioinfo:knnclassify:KNotScalar'));
end

if K<1
    error(message('bioinfo:knnclassify:KLessThanOne'));
end

if isnan(K)
    error(message('bioinfo:knnclassify:KNaN'));
end

if nargin < 6
    rule = 'nearest';
elseif ischar(rule)
    
    % lots of testers misspelled consensus.
    if strncmpi(rule,'conc',4)
        rule(4) = 's';
    end
    ruleNames = {'random','nearest','farthest','consensus'};
    i = find(strncmpi(rule, ruleNames,numel(rule)));
    if isempty(i)
        error(message('bioinfo:knnclassify:UnknownRule', rule));
    end
    rule = ruleNames{i};
    %     end
else
    error(message('bioinfo:knnclassify:InvalidRule'));
end

if distance ==1
[dIndex,D] = knnsearch(TRAIN,sample,'distance', 'euclidean','K',K);
disp('Its euclidean');
elseif distance==2 
    [dIndex,D] = knnsearch(TRAIN,sample,'distance', @CP_MinDist3,'K',K);
    %[dIndex,D] = knnsearch(TRAIN,sample,'distance', @ EU_MinDist1,'K',K);
else
    [dIndex,D] = knnsearch(TRAIN,sample,'distance', @CP_MinDist_K,'K',K);
%disp('CP mymindist');
end
% find the K nearest
if K >1
    classes = gindex(dIndex);
    % special case when we have one sample(test) point -- this gets turned into a
    % column vector, so we have to turn it back into a row vector.
    if size(classes,2) == 1
        classes = classes';
    end
    % count the occurrences of the classes
    
    counts = zeros(m,ngroups);
    for outer = 1:m
        for inner = 1:K
            counts(outer,classes(outer,inner)) = counts(outer,classes(outer,inner)) + 1;
        end
    end
    
    [L,outClass] = max(counts,[],2);
    
    % Deal with consensus rule
    if strcmp(rule,'consensus')
        noconsensus = (L~=K);
        
        if any(noconsensus)
            outClass(noconsensus) = ngroups+1;
			if isnumeric(group) || islogical(group)
				groups(end+1) = {'NaN'};
			else
				groups(end+1) = {''};
			end
        end
    else    % we need to check case where L <= K/2 for possible ties
        checkRows = find(L<=(K/2));
        
        for i = 1:numel(checkRows)
            ties = counts(checkRows(i),:) == L(checkRows(i));
            numTies = sum(ties);
            if numTies > 1
                choice = find(ties);
                switch rule
                    case 'random'
                        % random tie break
                        
                        tb = randsample(numTies,1);
                        outClass(checkRows(i)) = choice(tb);
                    case 'nearest'
                        % find the use the closest element of the equal groups
                        % to break the tie
                        for inner = 1:K
                            if ismember(classes(checkRows(i),inner),choice)
                                outClass(checkRows(i)) = classes(checkRows(i),inner);
                                break
                            end
                        end
                    case 'farthest'
                        % find the use the closest element of the equal groups
                        % to break the tie
                        for inner = K:-1:1
                            if ismember(classes(checkRows(i),inner),choice)
                                outClass(checkRows(i)) = classes(checkRows(i),inner);
                                break
                            end
                        end
                end
            end
        end
    end
    
else
    outClass = gindex(dIndex);
end

% Convert back to original grouping variable
if isa(group,'categorical') % this is true also for nominal and ordinal
	glevels = group([]);
	glevels(1:numel(groups),1) = groups;
	outClass = glevels(outClass);
elseif isnumeric(group) || islogical(group)
    groups = str2num(char(groups)); %#ok
    outClass = groups(outClass);
elseif ischar(group)
    groups = char(groups);
    outClass = groups(outClass,:);
else %if iscellstr(group)
    outClass = groups(outClass);
end

