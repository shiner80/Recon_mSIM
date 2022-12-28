function ThunderS_PL = importThunderStormCSV(FileName,PxSize)

ThunderS_PL = readtable(FileName);

% Reshuffle Table Columns
ThunderS_PL = table2array(ThunderS_PL);
ThunderS_PL = [ThunderS_PL(:,3), ThunderS_PL(:,4), ThunderS_PL(:,2)];

ThunderS_PL(:,1:2) = ThunderS_PL(:,1:2)./PxSize;
end