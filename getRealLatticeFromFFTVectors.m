function [RealLattice, RealVectors] = getRealLatticeFromFFTVectors(LatticeVectors,ImageSize)

Area = sqrt(sum(cross([LatticeVectors(1,:),0], [LatticeVectors(2,:),0]).^2));
RealVectors(1,:) = LatticeVectors(1,:)*[0 1; -1 0]/Area.*ImageSize;
RealVectors(2,:) = LatticeVectors(2,:)*[0 1; -1 0]/Area.*ImageSize;


VectorModule = sqrt(RealVectors(:,1).^2 + RealVectors(:,2).^2);
Extent = round(10*ImageSize/VectorModule(1));

% Generate a line of dots along vector 1 
listX = [-Extent:1:Extent].*(RealVectors(1,1));
listY = [-Extent:1:Extent].*(RealVectors(1,2));

Extent = round(10*ImageSize/VectorModule(2));
gridX = repmat(listX, 2*Extent + 1,1);
gridY = repmat(listY, 2*Extent + 1,1);

listVect2X = ([-Extent:1:Extent].*(RealVectors(2,1)))';
listVect2Y = ([-Extent:1:Extent].*(RealVectors(2,2)))';

gridVect2X = repmat(listVect2X,1,length(listX));
gridVect2Y = repmat(listVect2Y,1,length(listX));

RealLattice = [gridX(:)+gridVect2X(:),gridY(:)+ gridVect2Y(:)];
idx = find(RealLattice(:,1)<0 | RealLattice(:,1)>ImageSize |...
    RealLattice(:,2)<0 | RealLattice(:,2)>ImageSize);
RealLattice(idx,:) = [];