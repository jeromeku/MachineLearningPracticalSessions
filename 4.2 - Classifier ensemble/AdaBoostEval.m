function [YappClassCumule, tauxErreurApp, YtestClassCumule, tauxErreurTest] = ...
                                AdaBoostEval(Xapp, Yapp, Xtest, Ytest, T, verbose)

if (nargin < 6)
    verbose = false;
end
                            
% tailles
nXapp = size(Xapp,1);
nXtest = size(Xtest,1);

% initialisations
D = zeros(nXapp, T+1); % poids
h = cell(T,1); % classifieurs
eps = zeros(T,1); % erreurs pond�r�es
alpha = zeros(T,1); % pond�rations de classifieurs
YappClass = zeros(nXapp, T); % classifications
YtestClass = zeros(nXtest, T); % classifications

% initialisation des poids pour la premi�re it�ration
D(:,1) = 1/nXapp;

% pour chaque it�ration
for t=1:T
    
    % apprentissage du classifieur
    h{t} = souchebinairetrain(Xapp, Yapp, D(:,t));
    
    % evaluation avec le classifieur
    YappClass(:,t) = souchebinaireval(h{t}, Xapp);
    
    % calcul de l'erreur pond�r�e
    eps(t) = sum(D(YappClass(:,t) ~= Yapp, t));
    
    % calcul du coef de pond�ration du classifieur
    alpha(t) = 1/2 * log( (1 - eps(t)) / eps(t) );
    
    % calcul des pond�rations pour l'�tape suivante
    D(:, t+1) = D(:, t) .* exp( -alpha(t) * YappClass(:,t) .* Yapp );
    D(:, t+1) = D(:, t+1) / sum(D(:, t+1));
    
    % evaluation avec le classifieur sur l'ensemble de test
    YtestClass(:,t) = souchebinaireval(h{t}, Xtest);
end

% �valution des performances au fur et � mesure des it�rations
% en apprentissage
YappClassCumule = sign(cumsum( (YappClass .* repmat(alpha', nXapp, 1)) , 2));
tauxErreurApp = sum(YappClassCumule ~= repmat(Yapp, 1, T))/nXapp * 100;
% en test
YtestClassCumule = sign(cumsum( (YtestClass .* repmat(alpha', nXtest, 1)) , 2));
tauxErreurTest = sum(YtestClassCumule ~= repmat(Ytest, 1, T))/nXtest * 100;
[tauxErreurTestMin, tauxErreurTestMinInd] = min(tauxErreurTest);

% affichage des r�sultats
if (verbose)
    figure();
    plot(tauxErreurApp, '-b'); hold on;
    plot(tauxErreurTest, '-r');
    plot(tauxErreurTestMinInd, tauxErreurTestMin, '.k', 'MarkerSize', 15);

    legend('Apprentissage', 'Test', ['Err min en test (' int2str(round(tauxErreurTestMin))...
        '%, it�r� ' int2str(round(tauxErreurTestMinInd)) ')'] );
    xlabel('Nombre de classifieur');
    ylabel('Taux d''erreur');
end



