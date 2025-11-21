function Ch = mutate(Ch, nbsl, nbmu, nbch)

if nbch > nbsl                                    % if there are children
    for nmu = 1 : nbmu
        nch              = randi(nbch-nbsl)+nbsl; % muting child number
        nbge             = length(Ch(nch).view);  % number of genes
        nge              = randi(nbge);           % muting gene number
        Ch(nch).acc(nge) = randi(3)-1;            % random acceleration
        Ch(nch).whe(nge) = -2 + randi(3);         % random wheel
    end
end
