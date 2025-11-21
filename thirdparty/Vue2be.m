function be = Vue2be(Vue) % numero du gène

Vue(find(Vue)) = 1; % 
be = bin2dec(num2str(Vue(1:numel(Vue)))) + 1; % entre 1 et 3 435 978 368

if be == 1
    'be = 1 dans Vue2be'
end
