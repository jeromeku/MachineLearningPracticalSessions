
% On fait le clustering de N=12 points en K=3 clusters. On r�p�te l'exp�rience
% 3 fois et obtient le resultat dans clus. Chaque colonne de clus
% repr�sente l'affectation des points pour chaque exp�rience.
N = 12;
clus =[

     1     2     3
     1     2     3
     1     2     3
     2     3     1
     2     3     1
     2     3     1
     3     1     2
     3     1     2
     3     1     2
     1     3     1
     1     3     1
     1     3     1];
 
 
 %%
 % Le but est de d�tecter les points qui sont tomb�s dans le m�me cluster (peu
 % importe le num�ro du cluster) sur les trois exp�riences. On remarque les
 % 3 premiers points sont dans le m�me cluster les 3 fois. Ceci se
 % manifeste par le motif [1 2 3] dans la matrice clus. Les points 4 � 6
 % font de m�me (motif [2 3 1]). Les 3 derniers points tombent aussi
 % ensemble � chaque fois (motif [1 3 1]). D�tecter les formes formes
 % revient � identifier ces motifs
 
[tmp tmp2 listeformesfortes]=unique(clus,'rows') ;

%%
% former les clusters donn�s par les formes fortes
Nff = max(listeformesfortes);
effectifs= zeros(Nff, 1);
newlist = zeros(N,1);
for c=1:Nff
    ind = find(listeformesfortes==c) ;    
    effectifs(c)=length(ind);
    newlist(ind)=c; 
end
% Nff : nombre de formes fortes
% newlist : contient les affectations des points dans les clusters trouv�s
% avec les formes fortes
% effectifs : contient le nombre de points de chaque cluster identifi� par
% les formes fortes
% on peut maintenant fourner K-means avec K = Nff
