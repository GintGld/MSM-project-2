function [di, dj] = v2c(div, djv, card)

% div, djv     dans le ref de la voiture
% di, dj, card dans le ref du circuit


switch card
    case 'Nord'
        di = -div;
        dj = djv;
    case 'Sud'
        di = div;
        dj = -djv;
    case'Ouest'
        di = -djv;
        dj = -div;
    case 'Est'
        di = djv;
        dj = div;
end

