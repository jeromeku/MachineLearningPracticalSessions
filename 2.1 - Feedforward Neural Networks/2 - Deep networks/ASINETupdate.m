function netout=ASINETupdate(netin,grad,rho)
%%
% Mise � jour des poids d'un r�seau
%
% netin: r�seau entr�e
% grad:  gradient
% rho: pas d'apprentissage
%  
% netout: r�seau sortie
%

netout=netin;

% On boucle sur chaque couche du r�seau
for l=1:netin.nLayers
    netout.weight{l}=netin.weight{l}-rho*grad.weight{l}; 
end