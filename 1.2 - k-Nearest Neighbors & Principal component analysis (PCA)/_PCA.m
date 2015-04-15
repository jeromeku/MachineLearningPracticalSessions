%% TP2

close all
clear all

%% Tests de l'ACP

load data_iris_usps_asi/uspsasi.mat

caract = 5;
lines = find(y == caract);

% r�cup�ration du caract�re <caract>
X = x(lines, :);

% pr�paration de l'ACP
[D, U, moy]=mypca(X);

i = 2;

figure();
subplot(3,3,1);
imagesc(reshape(X(1,:),16,16)')
colormap gray;
title('Image initiale');

for q = [5 10 22 30 57 80 100 256] 

    % r�cup�ration des composantes principales
    P = U(:, 1:q);

    % projection sur les composantes principales
    Ct = projpca(X, moy, P);

    % reconstruction des donn�es initiales
    Xhat = reconstuctpca(Ct, P);

    % representation de la reconstruction
    subplot(3,3,i);
    imagesc(reshape(Xhat(1,:),16,16)')
    title(['Image reconstitu�e q = ' int2str(q)]);
    colormap gray;
    
    i = i + 1;
end

% On remarque que comme pr�vu, plus on ajoute de composantes sur lequelles
% on projette, plus l'image reconstitu�e est proche de l'image initiale. La
% diff�rence entre l'image initiale et l'image avec toutes les composantes
% est sans doute due aux erreurs num�riques lors des projections.

% nombre de CP appropri�
figure();
qteRepresentee = cumsum(D)/sum(D)*100;
plot(qteRepresentee);
title('Quantit� de donn�es repr�sent�es');
xlabel('Nombre de CP');
ylabel('Pourcentage d''information');
fprintf('Nombre de CP pour avoir 95%% : %i\n', find(qteRepresentee > 95, 1));

% Avec <nbCP>, on aura 95% de l'information reconstruite. Dans notre
% exemple, 57 composantes principales (sur les 256 possibles).
% 
% Etant donn� l'allure de la courbe, cette valeur nous semble un bon
% compromis.

%% Visages propres

% chargements des donn�es

load YaleFace/Subset1YaleFaces.mat

X1 = X;
Y1 = Y;

load YaleFace/Subset2YaleFaces.mat

X2 = X;
Y2 = Y;

load YaleFace/Subset3YaleFaces.mat

X3 = X;
Y3 = Y;

% calcul de l'ACP sur le premier ensemble
[D, U, moy]=mypca(X1);


%% Visualisation des r�sultats de l'ACP

% visage moyen
figure();
imagesc(reshape(moy,50,50));
colormap gray;
title('Visage moyen');

% visages propres
figure();
for i=1:9
    subplot(3,3,i);
    imagesc(reshape(U(:,i),50,50));
    colormap gray;
    title(['Visage propre n�' int2str(i)]);
end

% quantit� d'info
figure();
qteRepresentee = cumsum(D)/sum(D)*100;
plot(qteRepresentee);
title('Quantit� de donn�es repr�sent�es');
xlabel('Nombre de CP');
ylabel('Pourcentage d''information');
fprintf('Nombre de CP pour avoir 95%% : %i\n', find(qteRepresentee > 95, 1));


%% Reconstruction

% visage a afficher
visage = 40;

i = 2;
figure();
subplot(3,3,1);
imagesc(reshape(X1(visage,:),50,50));
title('Visage initial');
colormap gray;

for q=[5 8 12 15 25 40 55 75]
    % r�cup�ration des composantes principales
    P = U(:, 1:q);
    
    % projection sur les composantes principales
    Ct = projpca(X1, moy, P);

    % reconstruction des donn�es initiales
    Xhat = reconstuctpca(Ct, P);
    
    % affichage
    subplot(3,3,i);
    imagesc(reshape(Xhat(visage,:),50,50));
    title(['Visage reconstruit avec q = ' int2str(q)]);
    colormap gray;
    
    i = i + 1;
end



%% D�termination des meilleurs k et q 
% 
% On determine les meilleurs k et q en utilisant le premier jeu de donn�es
% en apprentissage et le deuxi�me en validation.

% pour chaque bloc
qVals = [5 8 10 12 14 16 20 40];
qValsLabel = {'q = 5', 'q = 8', 'q = 10', 'q = 12', 'q = 14', 'q = 16', 'q = 20', 'q = 40'};
kmax = 15;

errVal = zeros(kmax, length(qVals));
for j = 1:length(qVals)
    
    % choix q
    q = qVals(j);
    
    % projection
    P = U(:, 1:q);
    Ct1 = projpca(X1, moy, P);
    Ct2 = projpca(X2, moy, P);
    
    % pour chaque k
    for k = 1:kmax
        
        % pr�diction
        [Y2pred, Dist] = knn(Ct2, Ct1, Y1, k);
        
        % calcul proportion d'erreur pour le k choisi
        errVal(k, j) = mean(Y2pred ~= Y2);
    end
end

% affichage erreur
figure();
plot(errVal);
title('Erreur de validation');
xlabel('k');
ylabel('Proportion d''erreur');
legend(qValsLabel);

% On voit qu'en choisissant k = 5, a partir d'une valeur suffisament grande
% de q, l'erreur devient nulle. Ceci �tant vrai � partir de q = 12, il
% n'est pas n�c�ssaire de conserver plus de composantes qui alourdirait la
% base de donn�es.
%
% Les valeurs optimales sont donc k = 5 et q = 12.

%% Test de performance
%
% On teste la performance de notre knn en utilisant le troisi�me jeu de
% donn�es en test.

qTests = [10 11 12 13 14];
qTestsLabel = {'q = 10', 'q = 11', 'q = 12', 'q = 13', 'q = 14'};
kTests = 4:6;

errTest = zeros(length(kTests), length(qTests));
for j = 1:length(qTests)
    
    % choix q
    q = qTests(j);
    
    % projection
    P = U(:, 1:q);
    Ct1 = projpca(X1, moy, P);
    Ct3 = projpca(X3, moy, P);
    
    % pour chaque k
    for i = 1:length(kTests)
        
        % choix k
        k = kTests(i);
        
        % pr�diction
        [Y3pred, Dist] = knn(Ct3, Ct1, Y1, k);
        
        % calcul proportion d'erreur pour le k choisi
        errTest(i, j) = mean(Y3pred ~= Y3);
    end
end

% affichage erreur
figure();
plot(kTests, errTest);
xlabel('k');
ylabel('Proportion d''erreur');
legend(qTestsLabel);

% On voit que les valeurs k = 5 et q = 12 sont effectivement les valeurs
% optimales pour les r�sultats sur l'ensemble de test. La proportion
% d'erreur reste de 22% mais c'est le meilleur resultat qu'on ai pu obtenir
% sur l'ensemble de test. Afin d'augmenter ce r�sultat, il faudrait
% agrandir la base d'apprentissage.

%% Conclusion
%
% Ce TP aura permis de voir que l'ACP permet de compression les donn�es de
% fa�on significatives. Par exemple, il est possible de conserver quasiment
% l'int�gralit� des donn�es d'une photo sur 13 composantes au lieu de 2500.
% 
% Cette compression permet par ailleurs de pouvoir utiliser des m�thodes
% comme le knn dans une base de taille r�duite par rapport aux donn�es
% initiales et donc d'augmenter grandement la rapidit� des calculs.














