%% ================ Nfold CV =========================
% Xint : donn�es issues du premier d�coupage de X en Xint et Xtest
Nbvoisins = (1:25)';
fprintf('\n Classification par knn - Nfold validation \n')
Nfold = 5;
for NumFold = 1:Nfold
    fprintf('NumFold : %i | ', NumFold)
    % extraction des donn�es du fold NumFold pour validation et le reste 
    %pour apprentissage
    [Xapp, Yapp, Xval, Yval] = SepareDataNfoldCV(Xint, Yint, Nfold, NumFold);
    MatDistApp = [];
    MatDistVal = [];
    fprintf('NbVoisins : ')
    for k = 1:length(Nbvoisins)
        NbKnn = Nbvoisins(k);
         fprintf('%i - ',NbKnn)
        %% apprentissage
        [Ypredapp, MatDistApp] = knn(Xapp, Xapp, Yapp, NbKnn, MatDistApp);
        errapp(k,NumFold) = mean(Ypredapp~=Yapp);

        %% validation
        [Ypredval, MatDistVal] = knn(Xval, Xapp, Yapp, NbKnn, MatDistVal);
        errval(k,NumFold) = mean(Ypredval~=Yval);
    end
    fprintf('\n')
end

% A la fin on a une matrice contenant les erreurs sur tous les folds pour
% chaque valeur de k=1, Kmax (ici Kmax = 25)
% Pour k=p fix�, la ligne p de errval donne les erreurs en validation du mod�le kNN (avec
% k=p) pour tous les folds consid�r�s. L'erreur de validation pour k=p fix�
% est obtenu en prenant la moyenne de la ligne p de errval.
% On peut faire proc�der de la m�me mani�re pour errapp.