function [gradW, gradIn] = backward_tanh(W, I, O, gradOut)
%Backward d�une couche de MLP
%avec une fonction de transfert tanh
%- W parametres de la couche : matrice (n entrees+1)*(n sorties)
%- I entrees de la couche : matrice 1 * n entrees
%- O sorties de la couche : matrice 1 * n sorties
%- gradOut Grad de L par rapport � O
%- gradW Grad de L par rapport � W
%- gradIn Grad de L par rapport � I
%Grad de tanh par rapport � S

fGrad = (1 - O.^2);
%Grad de L par rapport � W
gradW = [I 1]' * (gradOut .* fGrad );
%Grad de L par rapport � I
gradIn = (W( 1 : ( end - 1), :) * (gradOut .* fGrad )')';

