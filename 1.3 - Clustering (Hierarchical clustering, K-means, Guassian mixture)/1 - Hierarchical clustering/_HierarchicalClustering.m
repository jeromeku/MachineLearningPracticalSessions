% TP3

clear all
close all

%% Calcul de distance
%
% <voir fonction distance.m>

%% Fonctionnement d'aggclust
% 
% aggclust cr�e une hi�rachie ascendante des clusters. Il initialise le
% niveau 1 en cr�ant 1 cluster par point. On boucle ensuite de 2 au nombre
% de points et en rassemblant � chaque fois les deux clusters les plus
% proches.

%% Fonction calc_dendro
% 
% Nous avons �crit une petite fonction qui se charge de calculer et
% d'afficher les deux dendrogrammes diff�rents (un pour chaque m�thode) �
% partir de donn�es.


%% Classification ASI4
% 
% On voit que la m�thode single n'arrive pas du tout � trouver de groupes
% alors que la m�thode complete forme bien des groupes qui semblent (au vu
% du nombre d'�tudiants par groupe) relativement bien r�partis.

load('asi4.mat');
fig = figure();
calc_dendro(data, true);
set(fig, 'Position', [100 100 850 420]);

%% DS2
%
% Afin de pouvoir visualiser graphiquement les clusters, on �crit une
% fonction show_clusters(data, level, nbClust) permettant d'afficher
% nbClust clusters.
%
% On constate que cette m�thode ne donne pas toujours les deux clusters
% que l'on attendrait (un par losange) mais regroupe parfois les pointes
% (un cluster avec les pointes inf�rieures et un avec les pointes
% sup�rieures).

load ds2.dat

data = mydownsampling(ds2, 30);

fig = figure();
[M, level, ~] = calc_dendro(data, true);
set(fig, 'Position', [100 100 850 420]);

% affichage

fig = figure();
for i=1:6
    subplot(2,3,i);
    show_clusters(data, level, i);
    title([int2str(i) ' clusters']);
end
set(fig, 'Position', [100 100 750 420]);

%% George
%
% Avec les donn�es "george", les clusters semblent plus proche de ce que
% l'on attends (1 cluster par lettre lorsque l'on choisi 6 clusters), et le
% r�sultat semble relativement stable vis � vis du sous-�chantillonage,
% contraitement � ce que l'on observait avec les donn�es "ds2".

load george.dat

data = mydownsampling(george, 15);

fig = figure();
[M, level, ~] = calc_dendro(data, true);
set(fig, 'Position', [100 100 850 420]);

% affichage

fig = figure();
for i=1:6
    subplot(2,3,i);
    show_clusters(data, level, i);
    title([int2str(i) ' clusters']);
end
set(fig, 'Position', [100 100 980 420]);

