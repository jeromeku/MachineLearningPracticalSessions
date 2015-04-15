function [D, U, moy]=mypca(X)
    [n,p] = size(X);
    
    %Centrage des donn�es
    moy = mean(X);
    X = X - ones(n,1) * moy;
    
    %Matrice de variance-covariance
    S = (1/n)*X'*X;
    
    %D�composition en valeurs propres
    [U, D] = eig(S);
    
    D = real(diag(D));
    [D, i] = sort(D, 'descend'); %i : indices de tri
    U = real(U(:,i));    
end