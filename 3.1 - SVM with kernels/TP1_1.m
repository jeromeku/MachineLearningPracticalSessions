%% Question 1
%
% Ce code g�n�re un jeu de donn�es en forme de grille d'�chec et l'affiche.

n = 500;
sigma=1.4;
[Xapp,yapp,Xtest ,ytest]=dataset_KM('checkers',n,n^2 ,sigma) ;
[n,p] = size(Xapp) ;
figure(1) ;
clf;
set(gcf,'Color',[1 ,1 ,1])
hold on
h1=plot(Xapp(yapp==1 ,1) ,Xapp(yapp==1 ,2) , '+r') ;
set(h1,'LineWidth',2) ;
h2=plot(Xapp(yapp== -1 ,1) ,Xapp(yapp== -1 ,2) ,'db') ;
set(h2,'LineWidth',2) ;

%% Question 2
%
% On calcule le kernel gaussien manuellement puis avec la fonction
% |svmkernel|. On notera le param�tre |kerneloption| qui est l'�cart type
% dans la formule du kernel gaussien.

% Compute a gaussian kernel and the matrix on your data with kerneloption =
% .5.
tic
D = (Xapp * Xapp'); % produit scalaire
N = diag(D); % normes
D = -2*D + N*ones(1, n) + ones(n,1) *N'; % Dij = ||t-s||^2 = -2 xi'*xj + ||xi||^2 + ||xj||^2
kerneloption = .5;
s = 2 * kerneloption^2;
K = exp(-D/s);
G = (yapp*yapp') .* K;
toc

% Compute the same gaussian kernel using the svmkernel function of the
% SVMKM toolbox
kernel = 'gaussian';
kerneloption = .5;
tic
K=svmkernel(Xapp, kernel, kerneloption);
G = (yapp*yapp') .* K;
toc

%% 2. c
% 
% On r�soud le probl�me de SVM dual avec cvx

e = ones(n,1);
C = 10000;
cvx_begin
    variable a(n)
    dual variables de dp dC
    minimize( 1/2*a'*G*a - e'*a )
    subject to
        de : yapp'*a == 0;
        dp : a >= 0;
        dC : a <= C;
cvx_end

%% 2.d
%
% On r�soud cette fois le probl�me avec le solveur de probl�me quadratique
% |monqp|

tic
lambda = eps^.5;
[alpha ,b,pos] = monqp(G,e,yapp ,0 ,C,lambda ,0) ;
toc

%% Question 3
%
% Affichage du r�sultat avec un |meshgrid|

[xtest1 xtest2] = meshgrid([ -1:.01:1]*3 ,[ -1:0.01:1]*3) ;

nn = length(xtest1);
Xgrid = [reshape(xtest1, nn*nn,1) reshape(xtest2 ,nn*nn,1) ];
Kgrid = svmkernel(Xgrid ,kernel ,kerneloption ,Xapp(pos ,:) ) ;
ypred = Kgrid*(yapp(pos) .*alpha) + b;
ypred = reshape(ypred,nn,nn);
contourf(xtest1 ,xtest2 ,ypred ,50) ; shading flat;
hold on;
[cc,hh]=contour(xtest1 ,xtest2 ,ypred ,[ -1 0 1] , 'k') ;
clabel(cc,hh) ;
set(hh, 'LineWidth', 2) ;
h1=plot(Xapp(yapp==1 ,1), Xapp(yapp==1 ,2) , '+r' , 'LineWidth' ,2) ;
h2=plot(Xapp(yapp== -1 ,1) ,Xapp(yapp== -1 ,2) , 'db' , 'LineWidth' ,2) ;
xsup = Xapp(pos ,:) ;
h3=plot(xsup(: ,1) ,xsup(: ,2) , 'ok', 'LineWidth',2) ;
axis([ -3 3 -3 3]) ;


%% Conclusion sur les temps de calcul
%
% On voit bien que les m�thodes de calcul optimis�es sont plus rapide que
% les m�thodes de calcul g�n�ralistes / manuelles.
%
% Par exemple, le calcul du kernel manuel (d�j� l�g�rement optimis�) prend
% 0,18s alors que la m�thode |svnkernel| obtient le m�me r�sultaten 0,018s,
% c'est � dire 10 fois plus rapidement.
%
% Par ailleurs, la r�solution du probl�me de minimisation par |cvx| prend 
% 20.5s contre 0.075s pour |monqp|. On voit ici que |cvx| est une toolbox
% tr�s pratique pour la souplesse qu'elle offre dans le formulation du
% probl�me de minimisation, mais qu'elle (et c'est logique) beaucoup moins
% rapide qu'une m�thode de r�solution optimis�e.
%
% Pour avoir des temps de calcul raisonnable quand on augmente le nombre de
% donn�es, il faut donc retravailler les probl�mes optimisation pour
% revenir � une forme standard permettant d'utiliser des solveurs
% optimis�s.

