function [View, view] = car_view(circuit, i, j, card, prof, larg)

% i, j            track referential
% larg, prof,     car referential

if nargin == 4 % number of inputs
    prof = 4;  % size of the car_view (blue) matrix 4x7
    larg = 7;
end

[n,p] = size(circuit);
a     = (larg-1)/2;
b     = prof - 2;
m     = max([a,b]);

if i <= m || j <= m || i > n-m || j > p-m
    View = zeros(prof,larg);
    view  = -1;
else
    switch card
        case 'Nord'
            View = circuit(i-b:i+1,j-a:j+a);
        case 'Sud'
            View = circuit(i-1:i+b,j-a:j+a);
            View = rot90(View,2);
        case 'Ouest'
            View = circuit(i-a:i+a,j-b:j+1);
            View = rot90(View,3);
        case 'Est'
            View = circuit(i-a:i+a,j-1:j+b);
            View = rot90(View,1);
    end

    view = Vue2be(View);
end

