%% M�thode d'�valuation
%
% Une composante importante du TP a consist� a travailler sur une fonction
% permettant d'�valuer les performances d'un classifieur en top i en
% calculant les taux de classification, rejet en ambiguit� et confusion.
%
% Ces scores sont calcul�s � partir d'une matrice $X$ avec une ligne par
% exemple � classifier, et une colonne par classe. La valeur $X_{ij}$ de
% la matrice correspond � une mesure de la confiance du classifieur dans le
% fait que l'exemple $i$ est de la classe $j$.
%
% Cette m�thode est donc g�n�ralisable et applicable pour �valuer n'importe
% quel r�sultat, que la matrice $X$ contienne des mesures, des rangs ou des
% votes.
%
% On consid�re qu'un exemple $i$ dont la classe r�elle est $j$ est "class�"
% en top $k$ si $X_{ij}$ fait parti des $k$ plus fortes valeurs de la ligne
% $X_{i\bullet}$, et que la valeur $X_{ij}$ n'a pas de valeur �gale en
% dehors des $k$ plus fortes valeurs de $X_{i\bullet}$, c'est � dire qu'il
% n'y a pas de conflit avec le score $X_{ij}$ en dehors du top $k$. Notons
% �galement que $X_{ij}$ doit �tre sup�rieur � 0, puisque les scores �gaux
% � z�ro correspondent aux cas non d�cid�s par le classifieur.
%
% On consid�re qu'un exemple $i$ dont la class� r�elle est $j$ est "rejet�
% en ambiguit�" en top $k$ si $X_{ij}$ fait parti des $k$ plus fortes
% valeurs de la ligne $X_{i\bullet}$ mais que la valeur $X_{ij}$ a au moins
% une valeur �gale en dehors des $k$ plus fortes valeurs de $X_{i\bullet}$,
% c'est � dire qu'il y a un conflit avec le score $X_{ij}$ en dehors
% du top $k$. L'exemple $i$ peut �galement �tre rejet� si aucun score de la
% ligne $X_{i\bullet}$ est sup�rieur � 0, c'est � dire que l'on rejette en
% ambiguit� un exemple pour lequel le classifieur ne donne aucun r�sultat.
% Ce cas arrive en combinaison de mesure par produit par exemple.
%
% On consid�re qu'un exemple $i$ dont la class� r�elle est $j$ est "confus"
% en top $k$ si $X_{ij}$ ne fait pas parti des $k$ plus fortes valeurs de
% la ligne $X_{i\bullet}$. C'est � dire les cas qui ne sont ni "class�s",
% ni "rejet�s".
%
%% Performance reco Top1 et Top5
%
% On mesure les performances des divers classifieurs en top 1 et top 5. On
% constate que les performances des classifieurs sont tr�s variables,
% allant pour le top 1 et 60 � 90%.
%
% En toute logique, les performances en top 5 sont sup�rieures � celles en
% top 1, allant de 88 � 96%.

clear all
load data

results = zeros(nbCl, 10);
for i = 1:nbCl
    [results(i,1:2:9), results(i,2:2:10)] = evaluerPerfs(Xapp{i}, yapp{i}, 5);
end

showTable(results, {'Classif T1', 'Rejet T1', 'Classif T2', 'Rejet T2', 'Classif T3', 'Rejet T3', 'Classif T4', 'Rejet T4', 'Classif T5', 'Rejet T5'}, {'Cl1', 'Cl2', 'Cl3', 'Cl4', 'Cl5'})
figure;
subplot(1,2,1);
plotResults(results(:,1:2:9)');
subplot(1,2,2);
plotResults(results(:,2:2:10)', 'rejet');

%% M�thodes de combinaison de type "Classe"
%
% On trace pour chaque m�thode (vote � la pluralit�, la majorit�, � la
% pluralit� pond�r�e) et pour chaque jeu de donn�es (apprentissage et test)
% les scores en classification, rejet d'ambiguit� et confusion.
%
% De mani�re g�n�rale, les performances obtenues sont bonnes, bien
% meilleures que les performances des classifieurs pris s�par�ment,
% montrant bien (au moins dans ce cas) l'apport des m�langes de
% classifieurs.
%
% On constate sans �tonnement que le vote � la pluralit� provoque moins de
% rejet que le vote � la majorit�, puisque les r�sultats du vote � la
% majorit� sont les m�mes que ceux du vote � la pluralit� en rejetant les
% cas qui ne sont pas vot�s par au moins 50% des classifieurs.
% 
% Sur le m�me principe, il n'est pas �tonnant de constater que le vote � la
% majorit� � beaucoup moins de confusion que le vote � la pluralit�,
% puisque les cas ambigus o� les classifieurs sont tr�s partag�s seront
% rejet�s en ambiguit�.
%
% Enfin, le vote � la pluralit� pond�r�e est celui qui offre les meilleurs
% r�sultats en classifications. Cependant, ceci peut �tre en partie
% expliqu� par le fait que l'utilisation de pond�ration des votes fait
% qu'il n'y a aucun cas dans le jeu de donn�es o� il y a ambiguit�. C'est
% donc la solution qui a le meilleur score en classification, mais qui a
% �galement le plus mauvais score (le plus fort) en confusion.
%
% Il est donc impossible de juger qu'une de ces solutions est meilleure que
% les autres puisque pour chaque, une augmentation des performances en
% classification entrainer une augmentation du taux de confusion. Le choix
% de la "meilleure" solution pour un cas donn� pourrait �tre fait en
% attribuant des co�ts aux 3 cas (classification, rejet, confusion) par
% exemple.

clear all
load data

lignes = {'Pluralit� app', 'Pluralit� test', 'Majorit� app', 'Majorit� test', 'Pond�ration app', 'Pond�ration test'};
colonnes = {'% Classification', '% Rejet', '% Confusion'};
results = zeros(6, 3);

[results(1,1), results(1,2), results(3,1), results(3,2), results(5,1), results(5,2)] = ...
    combinaisonClasse(Xapp, Xapp, yapp{1});
[results(2,1), results(2,2), results(4,1), results(4,2), results(6,1), results(6,2)] = ...
    combinaisonClasse(Xtest, Xapp, ytest{1});

results(:,3) = 1 - results(:,2) - results(:,1);

showTable(results*100, colonnes, lignes);

lignesVote = lignes;
resultsVote = results;
save('resultsVote', 'resultsVote', 'lignesVote');

%% M�thodes de combinaison de type "Rang"
%
% On essaye maintenant des m�thodes de combinaison de type rang. On ne
% consid�re donc plus les probabilit�s en sortie des classifieurs mais
% simplement l'ordre de ces probabilit�s, correspondantes au rang de chaque
% pr�diction.
%
% On constate que les m�thodes de type Borda-Count sont toutes tr�s proches
% les unes des autres, entre 96 et 98% de bonne classification en top 1.
% 
% La meilleure des m�thodes de Borda-Count est sans conteste la m�thode de
% Borda-Count avec poids, pond�r�e. Ce m�thode associe a chaque rang un
% poids qui est $c^(r-1)$ o� $c$ est une constante dans $[0,1]$ et $r$ le
% rang.
%
% La m�thode du meilleur rang peut �galement �tre int�ressante si on tol�re
% un tr�s fort taux de rejet en ambiguit�. En effet, cette m�thode produit
% tr�s peu d'erreurs en top 1 (0,03% en test), mais rejette beaucoup (77%
% en test).

clear all
load data

lignes = {'BC moyenne app', 'BC moyenne test', ...
          'BC poids app', 'BC poids test', ...
          'BC moyenne pond�r� app', 'BC moyenne pond�r� test', ...
          'BC poids pond�r� app', 'BC poids pond�r� test', ...
          'Meilleur rang app', 'Meilleur rang test'};
colonnes = {'% Classification', '% Rejet', '% Confusion'};
results = cell(length(lignes), 2);

[results{1,1}, results{1,2}, ...
 results{3,1}, results{3,2}, ...
 results{5,1}, results{5,2}, ...
 results{7,1}, results{7,2}, ...
 results{9,1}, results{9,2}] = combinaisonRang(Xapp, Xapp, yapp{1});

[results{2,1}, results{2,2}, ...
 results{4,1}, results{4,2}, ...
 results{6,1}, results{6,2}, ...
 results{8,1}, results{8,2}, ...
 results{10,1}, results{10,2}] = combinaisonRang(Xtest, Xapp, ytest{1});

results = cell2mat(cellfun(@(x) x', results, 'UniformOutput', false));
results(:,11:15) = 1 - results(:,1:5) - results(:,6:10);

showTable(results(:,1:5:end)*100, colonnes, lignes);
showTable(results(:,5:5:end)*100, colonnes, lignes);

screen = get(0,'screensize');
f = figure('Position',[0,0,screen(3),screen(4)-100]); movegui(f,'northwest')
subplot(2,3,1);
plotResults(results(:,1:5)', 'classification', lignes)
subplot(2,3,2);
plotResults(results(:,6:10)', 'rejet', {})
title('R�sultats pour toutes les m�thodes');
subplot(2,3,3);
plotResults(results(:,11:15)', 'confusion', {})

subplot(2,3,4);
plotResults(results(1:8,1:5)', 'classification', {})
subplot(2,3,5);
plotResults(results(1:8,6:10)', 'rejet', {})
title('R�sultats pour les m�thodes Borda-count');
subplot(2,3,6);
plotResults(results(1:8,11:15)', 'confusion', {})

lignesRang = lignes;
resultsRang = results;
save('resultsRang', 'resultsRang', 'lignesRang');

%% M�thode de combinaison de type "Mesure"
%
% Essayons maintenant des m�thodes de combinaison de type mesure. On
% utilise donc directement les scores en sortie des classifieurs, affect�s
% � chaque classe pour chaque exemple.
% 
% Ces scores peuvent �tre combin�s par somme ou produit, pond�r�s ou non.
%
% Dans notre cas, les m�thodes de somme donnent des meilleurs r�sultats que
% le produit sur tous les plans : taux plus fort en classification et plus
% faible en rejet et en confusion.

clear all
load data

lignes = {'Somme app', 'Somme test', ...
          'Produit app', 'Produit test', ...
          'Somme pond�r� app', 'Somme pond�r� test', ...
          'Produit pond�r� app', 'Produit pond�r� test'};
colonnes = {'% Classification', '% Rejet', '% Confusion'};
results = cell(length(lignes), 2);

[results{1,1}, results{1,2}, ...
 results{3,1}, results{3,2}, ...
 results{5,1}, results{5,2}, ...
 results{7,1}, results{7,2}] = combinaisonMesure(Xapp, Xapp, yapp{1});

[results{2,1}, results{2,2}, ...
 results{4,1}, results{4,2}, ...
 results{6,1}, results{6,2}, ...
 results{8,1}, results{8,2}] = combinaisonMesure(Xtest, Xapp, ytest{1});

results = cell2mat(cellfun(@(x) x', results, 'UniformOutput', false));
results(:,11:15) = 1 - results(:,1:5) - results(:,6:10);

showTable(results(:,1:5:end)*100, colonnes, lignes);
showTable(results(:,5:5:end)*100, colonnes, lignes);

screen = get(0,'screensize');
f = figure('Position',[0,0,screen(3),screen(4)-400]); movegui(f,'northwest')
subplot(1,3,1);
plotResults(results(:,1:5)', 'classification', lignes)
subplot(1,3,2);
plotResults(results(:,6:10)', 'rejet', {})
subplot(1,3,3);
plotResults(results(:,11:15)', 'confusion', {})

lignesMes = lignes;
resultsMes = results;
save('resultsMes', 'resultsMes', 'lignesMes');

%% Comparaison des m�thodes
% 
% On se propose finalement de comparer les performances des diff�rentes
% m�thodes en test (les r�sultats en apprentissage et en test �tant
% quasiment identique, inutile de doubler la quantit� de donn�es �
% analyser).
%
% En top 1, on affiche un tableau des r�sultats, tri� par taux de
% classification. On voit que la majorit� des m�thodes sont proches les
% unes des autres, mais que le vote pond�r� donne les meilleurs r�sultats.
%
% Il peut �tre int�ressant de chercher le front de Pareto des solutions �
% notre disposition, afin de savoir quelles sont r�ellement les solutions
% les plus interessantes au sens d'une optimisation multi-crit�re visant a
% maximiser le taux de classification et minimiser le taux de confusion
% (math�matique, cela revient �galement � minimiser le taux de rejet).
%
% On constate que le front de Pareto en top 1 contient le vote � la
% pluralit�, le vote � la majorit�, le vote pond�r� et le meilleur rang.
% Ces r�sultats sont particuli�rement �tonnant puisqu'ils ne font
% apparaitre quasiment que des m�thodes de type vote, et une m�thode de
% type rang qui rejette �norm�ment lui permettant d'avoir un taux
% imbattablement faible en confusion la pla�ant dans le front.
%
% Cependant, on ne peut bien s�r pas g�n�raliser ces r�sultats obtenus sur
% un cas particulier. Par ailleurs, il est important de noter que les
% diff�rences entres les m�thodes sont tr�s faibles pour la majorit�
% d'entre elles et que ce classement est donc peu significatif.
%
% Enfin, on peut �galement regarder l'�volution des performances des
% diff�rentes m�thodes du top 1 au top 5 (affich� uniquement pour les
% m�thodes ayant un taux de classification sup�rieur � 95% afin que le
% graphe reste lisible). Globalement, les r�sultats restent tr�s
% "parall�le", une m�thode d�passe rarement une autre.

clear all;

% load results
load resultsMes
load resultsVote
load resultsRang
resultsVote = [repmat(resultsVote(:,1), 1, 5) repmat(resultsVote(:,2), 1, 5) repmat(resultsVote(:,3), 1, 5)];
colonnes = {'% Classification', '% Rejet', '% Confusion'};

% merge all
results = [resultsVote ; resultsRang ; resultsMes];
lignes = [lignesVote lignesRang lignesMes];

% remove app results
results = results(2:2:end, :);
lignes = lignes(2:2:end);

% show table
[~, inds] = sort(results(:,1), 'descend');
showTable(results(inds,1:5:end)*100, colonnes, lignes(inds));

% front pareto
[~, indsPareto] = prtp(results(:,6:5:end));
showTable(results(indsPareto,1:5:end)*100, colonnes, lignes(indsPareto));

% filter good enougth methods
inds = find(results(:,1) > .95);
results = results(inds, :);
lignes = lignes(inds);

% plot
colors = {'b', 'r', 'g', 'k'};
styles = {'-x', '--o'};
screen = get(0,'screensize');
f = figure('Position',[0,0,screen(3),screen(4)-400]); movegui(f,'northwest')
subplot(1,3,1);
plotResults(results(:,1:5)', 'classification', lignes, colors, styles)
subplot(1,3,2);
plotResults(results(:,6:10)', 'rejet', {}, colors, styles)
subplot(1,3,3);
plotResults(results(:,11:15)', 'confusion', {}, colors, styles)
