%% Question 1
%
% Ce code g�n�re un jeu de donn�es en forme de grille d'�chec et l'affiche.

n = 500;
sigma=1.4;
[Xapp,yapp,Xtest ,ytest]=dataset_KM('checkers',n,n^2 ,sigma) ;
[n,p] = size(Xapp) ;


for kerneloption = 2:15
    
    % Affichage
    figure ;
    clf;
    set(gcf,'Color',[1 ,1 ,1])
    hold on
    h1=plot(Xapp(yapp==1 ,1) ,Xapp(yapp==1 ,2) , '+r') ;
    set(h1,'LineWidth',2) ;
    h2=plot(Xapp(yapp== -1 ,1) ,Xapp(yapp== -1 ,2) ,'db') ;
    set(h2,'LineWidth',2) ;
    title(['Degr� ' int2str(kerneloption)]);
    
    %% Question 2
    %
    % On calcule le kernel gaussien manuellement puis avec la fonction
    % |svmkernel|. On notera le param�tre |kerneloption| qui est l'�cart type
    % dans la formule du kernel gaussien.

    % Compute a gaussian kernel and the matrix on your data with kerneloption =
    % .5.
    % D = (Xapp * Xapp'); % produit scalaire
    % N = diag(D); % normes
    % D = -2*D + N*ones(1, n) + ones(n,1) *N'; % Dij = ||t-s||^2 = -2 xi'*xj + ||xi||^2 + ||xj||^2
    % kerneloption = .5;
    % s = 2 * kerneloption^2;
    % K = exp(-D/s);
    % G = (yapp*yapp') .* K;

    % Compute the same gaussian kernel using the svmkernel function of the
    % SVMKM toolbox
    kernel = 'poly';
    K=svmkernel(Xapp, kernel, kerneloption);
    G = (yapp*yapp') .* K;

    %% 2.d
    %
    % On r�soud cette fois le probl�me avec le solveur de probl�me quadratique
    % |monqp|

    lambda = eps^.5;
    [alpha ,b,pos] = monqp(G,e,yapp ,0 ,C,lambda ,0) ;

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

end

%%
%
% Les degr�s de 2 � 5 n'ont pas permis d'obtenir de r�sultats satisfaisants.
% Par contre, les degr�s 6 et 7 ont permis d'obtenir des r�sultats
% satisfaisants. Les degr�s sup�rieurs � 8 ont ensuite "diverg�s" et n'ont
% pas permis d'avoir de bons r�sultats.

