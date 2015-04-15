% Tire des indices de bootstrap
%
% n : nombre d'�l�ments dans l'ensemble
% m : nombre d'�l�ments � tirer
function [bag, obag] = tireBootstrap(n, m)
    
    bag = randi(n, m, 1);
    obag = setdiff(1:n, bag);

end