%% TP10

close all
clear all
clc

%% R�gression logistique binomiale
%
%% Fonctions cod�es
% 
% On code plusieurs fonctions permettant de faire une r�gression lin�raire.

%% Application aux donn�es clowns
%
% Apr�s avoir s�par� les donn�es en un ensemble de test et un ensemble
% d'apprentissage (80% en test / 20% en apprentissage), on applique les
% fonctions vues ci-dessus.

load clownsv7.mat

% Labels r�encod�s de -1 / 1 � 0 / 1
z = EncoderLabel01(y);

% Partage des donn�es en deux : Apprentissage et Test
[xapp, zapp, xtest, ztest] = splitdata(X, z, 0.2);
n = size(X, 1);
napp = size(xapp, 1);
ntest = size(xtest, 1);

%% Fronti�re de d�cision lin�aire 
% 
% On calcul d'abord la r�gression sur une matrice $\phi = [\mathbb{1} x_1
% x_2]$ afin d'obtenir une fronti�re de d�cision lin�aire.
%
% On obtient alors une erreur d'environ 18% avec cette fronti�re lin�aire.
% Cette erreur est raisonnable mais reste assez importante, d'autant qu'on
% pourrait sans doute beaucoup l'am�liorer en utilisant une fronti�re de
% d�cision quadratique plus complexe et plus adapt�e aux donn�es.
%  
% Lorsque l'on cherche � classifier les donn�es de test � partir des
% param�tres de d�cisions obtenus avec les donn�es d'apprentissage, on se
% rend compte que la diff�rence d'erreurs est assez faible entre les
% donn�es d'apprentissage et de tests.

% matrices de donn�es
phiApp = [ones(napp,1) xapp];
phiTest = [ones(ntest,1) xtest];

% application de la regression logistique
[theta,L] = ma_reg_log(phiApp, zapp);

% calcul des classes
zappExp = round(probaAPosteriori(theta, phiApp));
ztestExp = round(probaAPosteriori(theta, phiTest));

% erreur 
errApp = sum(zappExp ~= zapp)/napp;
errTest = sum(ztestExp ~= ztest)/ntest;

fprintf('Erreur en apprentissage : %i %%\n', round(errApp*100));
fprintf('Erreur en test : %i %%\n', round(errTest*100));

% calcul de la fronti�re de d�cision
xFront = [min(X(:,1)) max(X(:,1))]';
yFront = -(theta(1) + theta(2)*xFront)/theta(3);

% affichage
figure;
plot(xapp(zapp == 1,1),xapp(zapp == 1,2),'xr'); hold on;
plot(xapp(zapp == 0,1),xapp(zapp == 0,2),'xb');
plot(xtest(ztest == 1,1),xtest(ztest == 1,2),'.r');
plot(xtest(ztest == 0,1),xtest(ztest == 0,2),'.b');
plot(xFront, yFront, '-g');

legend('Apprentissage', 'Apprentissage', 'Test', 'Test', 'Fronti�re', 'Location', 'Best');

% evolution critere de convergence
figure;
plot(L);

%% Fronti�re de d�cision quadratique
% 
% On r�alise donc une froni�re de d�cision quadratique afin d'am�liorer la
% performance de l'algorithme.
%
% On calcule pour cela la r�gression logistique avec la matrice $\phi = [1
% ~ x_1 ~ x_2 ~ x_1 x_2 ~ x_1^2 ~ x_2^2]$.
%
% Le reste fonctionne de la m�me fa�on que pour une fronti�re lin�aire, on
% a simplement chang� d'espace. La seule diff�rence est que la fronti�re
% est quadratique, donc � tracer avec la fonction |contour| de Matlab.
%
% L'erreur tombe � 10%, soit presque la moiti� de l'erreur avec une
% fronti�re lin�aire. Cette erreur reste assez important car les donn�es
% sont tr�s m�lang�es autour de la fronti�re, il semble donc difficile de
% mieux s�parer les donn�es le plus excentr�es des milieux de classes.
%
% La meilleure solution pour diminuer le taux d'erreur serait de rejeter
% les points incertains trop proche de la fronti�re de d�cision. Cependant,
% l'inconv�nient de c

% matrices de donn�es
phiApp = [ones(napp,1) xapp xapp(:,1).*xapp(:,2) xapp.^2];
phiTest = [ones(ntest,1) xtest xtest(:,1).*xtest(:,2) xtest.^2];

% application de la regression logistique
[theta,L] = ma_reg_log(phiApp, zapp);

% calcul des classes
zappExp = round(probaAPosteriori(theta, phiApp));
ztestExp = round(probaAPosteriori(theta, phiTest));

% erreur 
errApp = sum(zappExp ~= zapp)/napp;
errTest = sum(ztestExp ~= ztest)/ntest;

fprintf('Erreur en apprentissage : %i %%\n', round(errApp*100));
fprintf('Erreur en test : %i %%\n', round(errTest*100));

% calcul de la fronti�re de d�cision
[xx yy] = meshgrid(-4:0.1:4,-4:0.1:4);
zz = theta(1) + theta(2)*xx + theta(3)*yy + theta(4)*(xx.*yy) + ...
    theta(5) * (xx.^2) + theta(6) * (yy.^2);

% affichage
figure;
plot(xapp(zapp == 1,1),xapp(zapp == 1,2),'xr'); hold on;
plot(xapp(zapp == 0,1),xapp(zapp == 0,2),'xb');
plot(xtest(ztest == 1,1),xtest(ztest == 1,2),'.r');
plot(xtest(ztest == 0,1),xtest(ztest == 0,2),'.b');
contour(xx, yy, zz, [0 0]);

legend('Apprentissage', 'Apprentissage', 'Test', 'Test', 'Fronti�re', 'Location', 'Best');

% evolution critere de convergence
figure;
plot(L);

%% R�gression logistique multimodale
% 
% Pour adapter le programme � 3 classes, il faudrait r�p�ter l'op�ration de
% mani�re � s�parer chaque groupe les uns des autres. Donc, pour l'ajout
% d'un (k+1)i�me groupe, on aura k fronti�res de plus � celles d�j�
% existantes.
% 
% En notant $\Theta = [\theta_1 ~ \theta_2 ~ ... ~ \theta_{k}]$ la matrice
% avec chaque param�tre de fronti�re en colonne, on peut simplement
% calculer les probabilit�s � posteriori. On aura dans la matrice de
% probabilit�s $P$ la probabilit� pour chaque fronti�re de d�cision dans
% chaque colonne.
%
% La fonction de calcul de probabilit� � posteriori est la suivant :
%
% [code]
%
% Le calcul de la fonction de r�gression logistique multimodale est plus
% compliqu�e. Nous n'avons pas r�ussi � faire fonctionner cette fonction
% correctement.
%
% La m�thode que nous avons appliqu� �tait de calculer $W$, $r$ et
% $\theta_i$ pour chaque colonne de la matrice $\Theta$. Malheureusement,
% cette m�thode ne semble pas fonctionner correctement.