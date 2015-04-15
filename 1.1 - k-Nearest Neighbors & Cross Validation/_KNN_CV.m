%% TP1

load('pima.mat');

%% Question 1
% Effectuer une br�ve analyse statistique des donn�es : moyenne, �cart-type
% de chaque variable.

M = mean(X)
Med = median(X)
ET = std(X)
figure();
boxplot(X);

% Ces diverses valeurs permettent d'avoir une vue globale des donn�es.

%% Question 2
% Impl�menter une m�thode de k-ppv (k plus proche voisins) avec une
% distance euclidienne.

% On utilise la fonction knn fournie qui renvoie les pr�dictions et les 
% distances calcul�es � partir des donn�es d'entr�es.

%% Question 3
% S�parer al�atoirement l�ensemble des donn�es en un ensemble
% d�apprentissage et un ensemble de test en respectant au mieux la
% proportion des classes. L�ensemble de test ne sera utilis� qu�une fois.
% Nota : voir la fonction splidata.m sur Moodle.
% 
% La fonction splitdata permet de s�parer les donn�es en respectant la
% proportion des classes. On s�pare ainsi notre ensemble de donn�es en deux
% ensembles de m�me taille.

[xapp, yapp, xtest, ytest] = splitdata(X, y, 0.5);

%% Question 4
% S�parer l�ensemble d�apprentissage en 2 ensembles : un autre ensemble
% d�apprentissage et un ensemble de validation. Tester votre m�thode k-ppv
% sur l�ensemble d�ensemble d�apprentissage et l�ensemble de validation
% pour diff�rentes valeurs de k ? N. Tracer une courbe de l�erreur
% d�apprentissage et une courbe de l�erreur de validation en fonction de k.
% Quelle est la valeur de k qui donne la plus faible erreur en validation ?

figure();

% on execute le code 3 fois pour voir son insatabilit�
for i=1:3
    % init de la matrice des erreurs pour chaque k de 1 � 30
    kmax = 30;
    errApp = zeros(kmax, 1);
    errVal = zeros(kmax, 1);

    % d�coupage en jeu d'apprentissage et de validation
    [xapp2, yapp2, xval2, yval2] = splitdata(xapp, yapp, 0.5);

    % pour chaque k
    for k = 1:kmax

        % pr�diction
        [ypredApp, Dist] = knn(xapp2, xapp2, yapp2, k);
        [ypredVal, Dist] = knn(xval2, xapp2, yapp2, k);

        % calcul d'erreur quadratique moyenne pour le k choisi
        errApp(k) = mean((ypredApp - yapp2).^2);
        errVal(k) = mean((ypredVal - yval2).^2);
    end

    % affichage des erreurs
    plot(errApp, 'o-');
    hold on;
    plot(errVal, 'or-');
    title('Erreur quadratique moyenne (m�thode knn)');
    leg = legend('Erreur d''apprentissage', 'Erreur de validation');
    set(leg,'Location','SouthEast');
    
    % meilleure valeur de k en validation

    [erreurMin, bestk] = min(errVal);
    fprintf('Meilleur k par m�thode knn : %i\n',bestk);
end

% Avec cette m�thode, on constate que la valeur de k trouv�e est tr�s
% d�pendante du d�coupage al�atoire des donn�es qui a �t� r�alis�, entre
% ensemble de test et ensemble d'apprentissage.
% 
% Pour r�soudre ce probl�me, on peut utiliser la m�thode de validation
% crois�e qui permet d'utiliser toute les donn�es pour r�aliser les tests
% et l'apprentissage de fa�on "rotative".

%% Question 5
% Refaire l�exp�rience en utilisant une m�thode de validation crois�e sur
% les donn�es d�apprentissage cr�es � la question 3. Quelle est la
% meilleure valeur de k ? Nota : voir sur Moodle la fonction
% SepareDataNfoldCV.m.
% 
% On utilise la fonction SepareDataNfoldCV pour d�couper l'ensemble
% d'apprentissage en plusieurs blocs afin d'y appliquer la m�thode de
% validation crois�e.

% constantes
kmax = 23;
Nfold = 20;
errApp = zeros(kmax, Nfold);
errVal = zeros(kmax, Nfold);

% pour chaque bloc
for NumFold = 1:Nfold
    % s�paration des donn�es
    [xapp2, yapp2, xval2, yval2] = SepareDataNfoldCV(xapp, yapp, Nfold, NumFold);
    
    % pour chaque k
    for k = 1:kmax

        % pr�diction
        [ypredApp, Dist] = knn(xapp2,xapp2,yapp2,k);
        [ypredVal, Dist] = knn(xval2,xapp2,yapp2,k);

        % calcul d'erreur quadratique moyenne pour le k choisi
        errApp(k, NumFold) = mean((ypredApp - yapp2).^2);
        errVal(k, NumFold) = mean((ypredVal - yval2).^2);
    end
end

% erreur d'apprentissage et de validation moyenne pour chaque k
errAppK = mean(errApp')';
errValK = mean(errVal')';

% affichage des erreurs
figure();
plot(errAppK, 'o-');
hold on;
plot(errValK, 'or-');
title('Erreur quadratique moyenne (m�thode validation crois�e)');
leg = legend('Erreur d''apprentissage', 'Erreur de validation');
set(leg,'Location','SouthEast');
hold off;

% meilleure valeur de k en validation
[erreurMin, bestk] = min(errValK);
fprintf('Meilleur k par m�thode de validation crois�e : %i\n',bestk);

% On voit effectivement que la m�thode de la validation crois�e est plus
% stable.
