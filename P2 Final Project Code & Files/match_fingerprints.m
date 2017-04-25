function [name] = match_fingerprints(fingerprint)
%% Matching of Fingerprints of Bird Calls
% Written by: Sarah Fraser
% ID: 20458408
% CS 489: Computational Audio
% Includes: 
% - creates a database of known bird call Fingerprints
% - for each point in the fingerprint, matches to the closest number
% - the bird with the most matches is determined to be the bird

% Globals
names = {'Blackbird', 'Black Tern','Blue Tit','Great Spotted Woodpecker','Corncrake','Mountain Chickadee','Hedge Sparrow','Northern Mockingbird','Wood Warbler','Wryneck'};

% Create Fingerprint 'Datbase'
blackbird_fp = load('Fingerprint Blackbird Call.mat');
black_tern_fp = load('Fingerprint Black Tern Call.mat');
blue_tit_fp = load('Fingerprint Blue Tit Call.mat');
great_spotted_woodpecker_fp = load('Fingerprint Great Spotted Woodpecker Call.mat');
corncrake_fp = load('Fingerprint Corncrake Call.mat');
mountain_chickadee_fp = load('Fingerprint Hedge Sparrow Call.mat');
hedge_sparrow_fp = load('Fingerprint Mountain Chickadee Call.mat');
northern_mockingbird_fp = load('Fingerprint Northern Mockingbird Call.mat');
wood_warbler_fp = load('Fingerprint Wood Warbler Call.mat');
wryneck_fp = load('Fingerprint Wryneck Call.mat');

fp_database = [blackbird_fp, black_tern_fp, blue_tit_fp, great_spotted_woodpecker_fp, corncrake_fp, mountain_chickadee_fp, hedge_sparrow_fp, northern_mockingbird_fp, wood_warbler_fp, wryneck_fp];

% Set up
num_bins = length(fingerprint);
matches = zeros(1,10);

% For each point in the fingerprint try to match from database
for i=1:num_bins
	fp_val = fingerprint(i);
	if fp_val ~= 0
		closest_match = 1;
		closest_diff = abs(fp_val - fp_database(1).bins(i));
		for j=1:length(fp_database)
			curr_value = fp_database(j).bins(i);
			diff_curr = abs(fp_val - curr_value);
			if diff_curr < closest_diff
				closest_diff = diff_curr;
				closest_match = j;
			end
		end
		matches(closest_match) = matches(closest_match) + 1;
	end
end

% Return the name of the matching bird
name = names(find(matches==max(matches)));

