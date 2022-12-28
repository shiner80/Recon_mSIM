function Vectors = findBaseVectors(PositionList, FFTsum, ImageSize, maxError)

% Compute distance from DC (center) dot
Distance = sqrt((PositionList(:,1)-ImageSize/2 +1).^2 +...
    (PositionList(:,2)-ImageSize/2 +1).^2);



% Sort dots based on Distance

[~, idx] = sort(Distance);
PositionList(:,1) = PositionList(idx,1);
PositionList(:,2) = PositionList(idx,2);


% Isolate DC dot
Center = [PositionList(1,1),PositionList(1,2)];
PositionList = PositionList(2:end,:);

count = 0;
RawVect = [];



% check for harmonics at twice the distance from each dot
% start from the closest dots from DC
% perform consistency check and store raw base vectors that pass it

for i=1:length(PositionList(:,1))
    disp(['Checking Peak ',num2str(i)])
    check = ...
        abs(PositionList(:,1)-2*PositionList(i,1)+Center(1))<maxError & ...
        abs(PositionList(:,2)-2*PositionList(i,2)+Center(2))<maxError & ...
        (PositionList(:,2)-Center(2))>0;
    
    
    if sum(check) >0
        disp(['Found Harmonic! for peak', num2str(i)]);
        count = count +1;
        RawVect(count,:) = [PositionList(i,1)-Center(1), PositionList(i,2)-Center(2)];
        % check consistency (sum of vectors need to point to another dot)
        if count > 0
            disp('Checking consistency');
            Outcome = checkConsistency(RawVect, Center, PositionList, maxError);
            if Outcome == 0
                RawVect(count,:) = [];
                count = count - 1;
            else
                disp(['Consistency Check Passed - Storing it as Raw Base Vector #', num2str(count)]);
               
            end
        end
    end
    % if three vectors are consistent move-on
    if count == 3
        break
    end
end

% if no vectors can pass consistency checks stop the routine
if count<3
    Vectors = [];
    warning('Identification of lattice points failed');
    warning('maybe check settings/thresholds for spots');
    
    return
end


% refine base vectors

% Calculate sum of base vectors
[comb_indexes,Comb_Cell] = combWithRep(RawVect, 2);
SumVectorCorr = zeros(length(Comb_Cell),2);



% find exact position of dots at sums of vectors
for i = 1:length(Comb_Cell)
    RawPosition = Center + sum(Comb_Cell{i});
    croppedFFT = FFTsum(RawPosition(2)-3:RawPosition(2)+3, ...
        RawPosition(1)-3:RawPosition(1)+3);
    x_par = polyfit([-3:3],croppedFFT(4,:),2);
    y_par = polyfit([-3:3],croppedFFT(:,4)',2);
    x_corr = - x_par(2)/(2*x_par(1));
    y_corr = - y_par(2)/(2*y_par(1));
    SumVectorCorr(i,:)= sum(Comb_Cell{i}) + [x_corr, y_corr];
end
% Perform least square to find precise lattice vectors

A = [sum(comb_indexes == 1,2), sum(comb_indexes ==2,2), sum(comb_indexes ==3,2)];
LatticeVectors(:,1) = lsqr(A,SumVectorCorr(:,1));
LatticeVectors(:,2) = lsqr(A,SumVectorCorr(:,2));

% find the vectors combination that gives sum closest to zero
A = [1 1 1; 1 1 -1;1 -1 1;1 -1 -1];
[dummy,idx] = min(abs(A*LatticeVectors(:,1)));
LatticeVectors(:,1) = LatticeVectors(:,1).*A(idx,:)';
LatticeVectors(:,2) = LatticeVectors(:,2).*A(idx,:)';

% correct each vector by 1/3 of the residual sum of the vectors.
residual = sum(LatticeVectors);
Vectors(:,1) =LatticeVectors(:,1) - 1/3*residual(1);
Vectors(:,2) =LatticeVectors(:,2) - 1/3*residual(2);
