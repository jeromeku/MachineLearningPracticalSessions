function [W1 W2] = mlp2c_init(m, n, o)
% Initialise les poids d'un perceptron multicouche � m neurones en entr�e,
% n neurones dans la couche cach�e, o neurones en sortie

W1 = ones(m, n);
W2 = ones(n, o);

