%% Codage et test des fonctions
%
% Afin de v�rifier le fonctionnement de la toolbox, j'ai test� les diverses
% fonctions avec deux probl�mes tr�s simple : un probl�me de r�gression de
% la fonction $y=2\times x$, et un probl�me de classification de dimension
% 1.
%
% Le r�seau test� est un r�seau MLP avec une couche cach�e, 1 entr�e et 1
% ou 2 sorties selon les cas.
%
% En utilisant la toolbox, on se rend compte que le choix des fonctions
% d'activiation � un impact fort sur les perfomances du mod�le. Par
% ailleurs, le fait que la m�thode utilise un pas fixe et un nombre
% d'it�ration fix� fait que le choix de ces param�tres est tr�s important :
% un pas trop faible rend la convergence tr�s lente, un pas trop grand fait
% diverger au lieu de converger.
%
% Une bonne am�lioration serait de fixer un crit�re de fin en plus d'un
% nombre d'it�ration maxmimum, et d'utiliser une m�thode � pas variable
% pour acc�l�rer la convergence.
%
% Notons �galement que pour augmenter l�g�rement la rapidit� des calculs et
% surtout le confort d'utilisation, j'ai ajout� un param�tre � la fonction
% |onlinegrad| qui poss�de d�sormais une option |verbose| indiquant si on doit ou non
% afficher toutes les it�rations.

% Exemple de probl�me de r�gression

clear all

net=ASINETfactory(1,[3 1],{'linear','linear'});

X = [1 2 3 4 5 6]';
Y = [2 4 6 8 10 12]';

[netout,learningErr,valError]=ASINETonlinegrad(net,X,Y,0.01,100,'mse', false);
YE=ASINETforward(netout,X);

%YE =
%    2.0510
%    4.0419
%    6.0328
%    8.0237
%   10.0146
%   12.0055

%%

% Exemple de probl�me de classification

clear all

net=ASINETfactory(1,[5 2],{'tanh','softmax'});

X = [1 2 3 7 8 9]';
Y = [0 0 0 1 1 1; 1 1 1 0 0 0]';

[netout,learningErr,valError]=ASINETonlinegrad(net,X,Y,0.001,1000,'nll', false);
YE=ASINETforward(netout,X)

%YE =
%    0.0095    0.9905
%    0.0185    0.9815
%    0.0518    0.9482
%    0.9666    0.0334
%    0.9761    0.0239
%    0.9791    0.0209

%% G�n�rer le jeu de test
% 
% On g�n�re un jeu de donn�es que l'on d�coupe en apprentissage (10%) et en
% validation (90%).

clear all

nX=1000;
X = zeros(nX,2);

X(1:nX/2  ,:) = randn(nX/2,2) + repmat([0 6], nX/2, 1);
X(nX/2+1:nX,1) = (rand(nX/2,1) - 0.5) * 6;
X(nX/2+1:nX,2) = X(nX/2+1:nX,1).^2 + 0.7*randn(nX/2,1);

Y = [ones(nX/2,1) ; zeros(nX/2,1)];

% d�coupage en apprentissage et test
[Xapp, Yapp, Xtest, Ytest] = splitdata(X, Y, 0.1);
plot(X(Y==1,1), X(Y==1,2), '.r'); hold on;
plot(X(Y==0,1), X(Y==0,2), '.b');
plot(Xapp(Yapp==1,1), Xapp(Yapp==1,2), 'or'); hold on;
plot(Xapp(Yapp==0,1), Xapp(Yapp==0,2), 'ob');
title('Jeu de test');

%% Cr�ation d'un r�seau
% 
% On se propose de tester un r�seau avec 2 fonctions d'activation |tanh|.
% Nous avons 2 entr�es qui sont les 2 dimensions de chaque donn�e $x$, et
% une sortie.
%
% On teste donc ce r�seau avec entre 1 et 10 neurones dans la couche
% cach�e.
% 
% Nontons qu'a partir des donn�es initiales, il est important de construire
% le bon vecteur cible � passer � la toolbox. Dans le cas d'une sortie de
% |tanh|, la cible contient des 0 et des 1.
% 
% On notera que le choix d'un crit�re type MSE se justifie par le fait
% qu'il faut pouvoir d�river la fonction, mais la vraie mesure du taux de
% bonne classification consiste � arrondir la sortie afin d'obtenir des 0
% et des 1, et de comparer � la cible.

% valeurs � tester
n_vals = 1:10;

% Stockage pour affichage
errApp = zeros(length(n_vals),1);
errVal = zeros(length(n_vals),1);
nbErrApp = zeros(length(n_vals),1);
nbErrVal = zeros(length(n_vals),1);

% Pour chaque nb de neurones dans la couche cach�e
for i = 1:length(n_vals)
    
    n = n_vals(i);

    net=ASINETfactory(2,[n 1],{'tanh','tanh'})
    [netout,learningErr,valError]=ASINETonlinegrad(net,Xapp,Yapp,0.01,250,'mse', true, Xtest, Ytest);
    YE=ASINETforward(netout,Xapp);
    YE2=ASINETforward(netout,Xtest);

    errApp(i) = learningErr(end);
    errVal(i) = valError(end);
    nbErrApp(i) = sum(round(YE) ~= Yapp);
    nbErrVal(i) = sum(round(YE2) ~= Ytest);
    
end

%%

figure;
subplot(1,2,1);
plot(n_vals, errApp, '*-r'); hold on
plot(n_vals, errVal, '*-b');
title('Valeur du crit�re en fin de calcul');
legend('Apprentissage', 'Validation');
subplot(1,2,2);
plot(n_vals, nbErrApp/length(Xapp), '*-r'); hold on
plot(n_vals, nbErrVal/length(Xtest), '*-b');
title('Taux de classification en erreur');
legend('Apprentissage', 'Validation');

%% Reconnaissance de caract�res
%
% On veut faire de la reconnaissance des caract�res du fichier |uspsasi|
% pour distinguer le 1 des 8.
%
% Le pr�traitement consiste � extraire uniquement les lignes qui nous
% int�ressent dans la matrice x, et � g�n�rer un vecteur y de -1 et de 1.
%
% On s�pare ensuite l'ensemble en appretissage (20%) et test (80%).
%
% Sans pr�-apprentissage, on obtient des r�sultats tr�s satisfaisants
% puisqu'on obtient un taux d'erreur en validation de seulement 7%. On peut
% sans doute esp�rer de meilleurs r�sultats en r�glant de fa�on plus
% pr�cise le pas et le nombre d'it�rations.
%
% On fait ensuite un pr�-apprentissage du r�seau. L'objectif est de
% stabiliser les calculs en ne partant pas d'un r�seau al�atoire, ce qui
% permet normalement de partir plus proche d'un minimum local.
%
% On obtient l�g�rement meilleurs que sans pr�-apprentissage : 5% de
% mauvaise classification. Par ailleurs, l'�cart-type de l'erreur de
% validation est 2 fois plus grand sans pr�-apprentissage qu'avec. On
% remarque donc que le pr�-apprentissage du r�seau permet de stabiliser la
% m�thode et d'acc�l�rer l'apprentissage r�el.

clear all
load uspsasi

% on ne garde que les 1 et les 8
x = [x(y==1,:); x(y==8,:)];
y = [-ones(sum(y==1),1); ones(sum(y==8),1)];
p = size(x,2);

% Stockage pour affichage
errApp = zeros(5,1);
errVal = zeros(5,1);
nbErrApp = zeros(5,1);
nbErrVal = zeros(5,1);

for i=1:5
    % d�coupage des donnes
    [xapp, yapp, xtest, ytest] = splitdata(x, y, 0.2);
    
    % calcul du r�seau
    net=ASINETfactory(p, [64 16 1],{'tanh','tanh','tanh'})
    [netout,learningErr,valError]=ASINETonlinegrad(net,xapp,yapp,0.05,50,'mse', true,xtest,ytest);
    YE=round(ASINETforward(netout,xapp));
    YE2=round(ASINETforward(netout,xtest));

    errApp(i) = learningErr(end);
    errVal(i) = valError(end);
    nbErrApp(i) = sum(YE ~= yapp);
    nbErrVal(i) = sum(YE2 ~= ytest);
end

figure;
subplot(1,2,1);
plot(1:5, errApp, '*-r'); hold on
plot(1:5, errVal, '*-b');
title('Valeur du crit�re en fin de calcul');
legend('Apprentissage', 'Validation', 'Location', 'best');
subplot(1,2,2);
plot(1:5, nbErrApp/length(xapp), '*-r'); hold on
plot(1:5, nbErrVal/length(xtest), '*-b');
title('Taux de classification en erreur');
legend('Apprentissage', 'Validation', 'Location', 'best');

std(errVal)

% Stockage pour affichage
errApp = zeros(5,1);
errVal = zeros(5,1);
nbErrApp = zeros(5,1);
nbErrVal = zeros(5,1);

for i=1:5
    % d�coupage des donnes
    [xapp, yapp, xtest, ytest] = splitdata(x, y, 0.2);
    
    % calcul du r�seau
    net=ASINETfactory(p, [64 16 1],{'tanh','tanh','tanh'})
    
    % pr�-apprentissage
    % pour chaque layer a pr�-apprendre
    H = xapp;
    for k = 1:net.nLayers - 1
        % construction du r�seau de pr�-apprentissage
        nbInputs = size(net.weight{k},1)-1
        nbInside = size(net.weight{k},2)
        netApp = ASINETfactory(nbInputs, [nbInside nbInputs],{net.type{k},'linear'})
        [netApp,~,~]=ASINETonlinegrad(netApp,H,H,0.0001,150,'mse', true);
        
        % sauvegarde du r�sultat
        net.weight{k} = netApp.weight{1};
        
        % entr�e du prochain pr�-apprentissage
        [~, Hmat]=ASINETforward(netApp,H);
        H=Hmat{2};
    end

    [netout,learningErr,valError]=ASINETonlinegrad(net,xapp,yapp,0.05,50,'mse', true,xtest,ytest);
    YE=round(ASINETforward(netout,xapp));
    YE2=round(ASINETforward(netout,xtest));

    errApp(i) = learningErr(end);
    errVal(i) = valError(end);
    nbErrApp(i) = sum(YE ~= yapp);
    nbErrVal(i) = sum(YE2 ~= ytest);
end

figure;
subplot(1,2,1);
plot(1:5, errApp, '*-r'); hold on
plot(1:5, errVal, '*-b');
title('Valeur du crit�re en fin de calcul');
legend('Apprentissage', 'Validation', 'Location', 'best');
subplot(1,2,2);
plot(1:5, nbErrApp/length(xapp), '*-r'); hold on
plot(1:5, nbErrVal/length(xtest), '*-b');
title('Taux de classification en erreur');
legend('Apprentissage', 'Validation', 'Location', 'best');

std(errVal)














