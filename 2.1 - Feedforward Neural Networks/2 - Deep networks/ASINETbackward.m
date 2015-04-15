function grad=ASINETbackward(net,state,gradOut)
%%
% Calcul du gradient des poids d'un r�seau pour un exemple donn�e
%
% net: reseau
% state: �tat du reseau pour un exemple
% gradOut: gradient du crit�re
% 
% grad: gradient des poids (m^eme repr�sentation qu'un reseau)


% Le gradient a la m^eme forme que le reseau d'entr�e 
grad.nLayers=net.nLayers;

nL=net.nLayers;


% On parcours le reseau en sens inverse en retropropagant l'erreur 
for l=nL:-1:1
  L = state{l+1};
  %Calcul du gradiant de la fonction de transfert
  switch lower(net.type{l})
  case 'linear'
    fGrad=ones(1,size(L,2));
  case 'tanh'
    fGrad=(1-L.^2);
  case 'sigm'
    fGrad=L.*(1-L);
  case 'softmax'
    fGrad=(1.-L).*L;
  case 'logsoftmax'
    fGrad=1-exp(L);
  otherwise
      error('Unknown transfert function');
  end
  %Calcul du gradient correspondant
  grad.weight{l} = [state{l} 1]' * (gradOut.* fGrad) ;
  %Calcul de l'erreur de la couche
  gradIn=  (  net.weight{l} (1:(end-1),:)*(gradOut.* fGrad)')';
  gradOut=gradIn;
end