function [div, djv, card] = c2v(di, dj, card)

% di, dj   dans le ref du circuit
% div, djv dans le ref de la voiture

if nargin == 2
    switch max(abs([di,dj]))
        case abs(di)
            if di < 0
                card = 'Nord';
            else
                card = 'Sud';
            end
        otherwise
            if dj < 0
                card = 'Ouest';
            else
                card = 'Est';
            end
    end
end

switch card
    case 'Nord'
        div  = -di;
        djv  = dj;
    case 'Sud'
        div  = di;
        djv  = -dj;
    case 'Ouest'
        div  = -dj;
        djv  = -di;
    case 'Est'
        div  = dj;
        djv  = di;
end

