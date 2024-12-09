function  [HIPshank, ECshank]=getshankECHIP(animal)


if strcmp(animal, 'TS91-2')==1
    HIPshank=4;
    ECshank=6;
elseif strcmp(animal, 'TS91-1')==1
    HIPshank=4;
    ECshank=7;
% elseif strcmp(animal, 'TS90-2')==1
%     HIPshank=4;
%     ECshank=7;
elseif strcmp(animal, 'TS89-2')==1
    HIPshank=4;
    ECshank=7;
elseif strcmp(animal, 'TS89-3')==1
    HIPshank=4;
    ECshank=7;
elseif strcmp(animal, 'TS89-1')==1
    HIPshank=4;
    ECshank=6; %7 is good too
elseif strcmp(animal, 'TS90-0')==1
    HIPshank=4;
    ECshank=6;
elseif strcmp(animal, 'TS88-3')==1
    HIPshank=4;
    ECshank=6;
elseif strcmp(animal, 'TS87-0')==1
    HIPshank=4;
    ECshank=7;
elseif strcmp(animal, '3xTg1-1')==1
    HIPshank=2;%2
    ECshank=5; %6
elseif strcmp(animal, '3xTg1-2')==1
    HIPshank=3;%3
    ECshank=6;
elseif strcmp(animal, 'TS116-2')==1
    HIPshank=3;
    ECshank=5;
elseif strcmp(animal, 'TS116-3')==1
    HIPshank=3;
    ECshank=5;
elseif strcmp(animal, 'newguy')==1
    HIPshank=4;
    ECshank=7;
elseif strcmp(animal, 'newguy')==1
    HIPshank=4;
    ECshank=7;
else
    disp('no shanks assigned')
end
   
   
   
   
   
end