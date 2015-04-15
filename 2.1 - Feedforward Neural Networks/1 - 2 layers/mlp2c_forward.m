function [C, O] = mlp2c_forward(W1, W2, X)
% calcule la sortie d'un perceptron multicouche de 2 couches avec une
% fonction de transfert tanh d�fini par ces matrices de param�tres W1 et
% W2

C = forward_tanh(W1, X);
O = forward_tanh(W2, C);