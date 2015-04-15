clear
close all

load netflix_data_probe.mat
load netflix_data_app.mat

%% 
% L'objectif du TP est d'�tudier le probl�me Netflix en essayant de
% d�terminer la note qu'une personne attribuerait � une film a partir des
% notes qu'elle a attribu�e aux autres films.
%
% Pour cela, on applique une m�thode factorielle qui consiste donc �
% factoriser la matrice de donn�es sous la forme d'un produit de 2 matrices
% plus petites $U$ et $V$.
% 
% Pour cela, on calcule les $k$ premiers vecteurs singuliers de la matrice.
% On utilisera pour cela la fonciton |lansvd| de PROPACK plutot que |svds|
% de Matlab pour des raisons d'optimisation.
%
% On estime ensuite les notes � "deviner" gr�ce � $U$ et $V$ et on les
% compare aux donn�es de tests pour �valuer la qualit� de la m�thode.
%
% On constate que plus on prends de vecteurs singuliers, plus les r�sultats
% sont bon, jusqu'� 30. Je n'ai pas test� plus loin pour des raisons de
% temps de calculs, mais il semblerai selon les r�sultats du challenge
% Netflix qu'il faille prendre beaucoup de vecteurs propres pour commencer
% � faire du sur-apprentissage.
%
% En plus de quelques am�lioration m�moire dans le calcul de l'erreur, j'ai
% essay� d'impl�menter une m�thode de soft-shrinkage. Malheureusement,
% cette m�thode n'a apport� aucune modification de l'erreur sup�rieure �
% $10^{-14}$, donc rien de significant.

% nombre de vecteurs singuliers
k = 50;

% Calcul des vecteurs singuliers
tic
[U,D,V] = svds(netflix_data_app, k);
disp(['Time to compute SVD with svds : ' num2str(toc) 's']);
U=0;V=0;D=0; % clear RAM
tic
[U, D, V] = lansvd(netflix_data_app, k, 'L');
diagD = diag(D);
disp(['Time to compute SVD with propack : ' num2str(toc) 's']);

% recherche des �l�ments non nuls dans probe (�l�ments � estimer)
[i,j,s] = find(netflix_data_probe);
nt = length(s);

% Reconstructions
for nbVS = 1:k;
    
    % hard shrinkage
    tic
    Err(nbVS) = 0;
    d = D(1:nbVS,1:nbVS);
    for ii=1:nt
        rec = U(i(ii),1:nbVS)*d*V(j(ii),1:nbVS)';
        err = (rec - s(ii))^2;
        Err(nbVS) = Err(nbVS) + err;
    end
    Err(nbVS) = Err(nbVS) / nt;
    disp(['Time to reconstruct for ' num2str(nbVS) ' rank without soft-shrinkage : ' num2str(toc) 's - Err : ' num2str(Err(nbVS))]);
    
    % soft shrinkage
    if (nbVS < k)
        ErrSS(nbVS) = 0;
        tic
        d = diagD(1:nbVS);
        d = diag(soft_shrinckage(d, D(nbVS+1), d(ceil(nbVS*2/3))));
        for ii=1:nt
            rec = U(i(ii),1:nbVS)*d*V(j(ii),1:nbVS)';
            err = (rec - s(ii))^2;
            ErrSS(nbVS) = ErrSS(nbVS) + err;
        end
        ErrSS(nbVS) = ErrSS(nbVS) / nt;
        disp(['Time to reconstruct for ' num2str(nbVS) ' rank with    soft-shrinkage : ' num2str(toc) 's - Err : ' num2str(ErrSS(nbVS))]);
        
    end
    
end

% Evolution de l'erreur
figure;
plot(Err);
title('Evolution de l''erreur en fonction du rang');

