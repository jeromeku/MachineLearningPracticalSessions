%%
%
% Le but du TP est d'�tudier diff�rentes m�thodes permettant de converger
% vers le minimum d'une fonction convexe de plusieurs variables.
%
% Pour ces m�thodes, on utile le gradient ou la matrice Hessienne afin de
% d�terminer la direction de descente permettant de faire d�croitre la
% fontion de co�t. On avance dans cette direction d'une valeur d�finie par
% un pas qui peut �tre fixe ou variable. Enfin, on it�re ce processus tant
% que le co�t varie de fa�on non n�gligeable (nous avons choisi de fixer le
% seuil � $10^{-5}$.

%% Pr�paration

clear all
close all
clc

% parametres du probleme
a = [1; 3];
b = [1; -3];
c = [-1; 0];

% Create a grid of x and y points
n = 100;
[X, Y] = meshgrid(linspace(-1.25, 2.5, n), linspace(-1.75, 2, n));
ptx = reshape(X, n*n,1);
pty = reshape(Y, n*n,1);
pt = [ptx pty];

% Define the function J = f(\theta)
Jmat = (1-pt(:,1)).^2 + 100*(pt(:, 2) - pt(:, 1).^2).^2;

% solution initiale
theta0 = [-1; 0];

%% Premi�re version avec $\alpha$ constant
%
% On r�alise un premier code avec un pas $\alpha$ constant. Ce pas est
% d�fini par des essais successifs pour trouver un pas adapt� au probl�me,
% c'est � dire convergeant � une vitesse satisfaisante : ni trop rapide, ni
% trop lent.
%
% Notons qu'en r�alit�, le pas d'avancement � chaque it�ration n'est pas
% constant car on ne normalise pas le gradient. Ainsi, le pas d'avancement
% r�el d�pend de la valeur du gradient, et est donc d'autant plus grand que
% la fonction augmente rapidement selon la direction de descente.
%
% Par ailleurs, on remarque que la fonction pr�sente une zone o� le co�t ne
% varie quasiment pas, donnant un gradient de valeur faible, et nous
% faisant donc faire de tr�s petits pas vers le minimum, rendant la
% convergence tr�s lente.

% pas alpha fix�
alpha =  0.002;

% variables pour la boucle et initialisation
Jlist = [];
grad = mongradient(theta0);
theta_old = theta0;
theta = theta0;
i = 1;

% initialiser la figure
close all;
init_fig(theta0, Jmat, n, X, Y);

% tant qu'on a pas converg�, on it�re
while norm(grad) > 1e-3 && i < 15000
    
    % calculs du nouveau theta
    grad = mongradient(theta);              % calcul du gradient
    direction = -grad;                      % direction de descente
    theta_old = theta;                      % sauvegarde ancien theta pour affichage
    theta = theta + alpha * direction;      % MAJ du point en cours
    
    % trace du theta courant
    h = plot([theta_old(1) theta(1)], [theta_old(2) theta(2)], '-ro');
    set(h, 'MarkerSize', 2, 'markerfacecolor', 'r');
    
    % calcul de J
    Jlist = [Jlist moncritere(theta)];
    i = i + 1;
end

% theta final
h = plot(theta(1,:), theta(2,:), 'ro');
set(h, 'MarkerSize', 8, 'markerfacecolor', 'r');
text(theta(1,1), theta(2,1)+0.025, ['\theta_{' int2str(i-1) '}'], 'fontsize', 15)
title('Evolution de \theta avec la m�thode 1');

% affichage �volution J
figure;
plot(Jlist);
title('Evolution du J avec la m�thode 1');

%% Deuxi�me version avec $\alpha$ variable
%
% Cette fois, on d�cide d'appliquer une r�gle permettant de faire varier
% $\alpha$ afin de converger plus vite.
%
% A chaque it�ration, si le $\alpha$ que l'on a nous permet de converger,
% on le multiplie par 1,15 afin d'essayer de converger plus vite �
% l'it�ration suivante.
%
% Sinon, si le $\alpha$ que l'on avait fait augmenter le co�t, alors on
% annule les calculs r�alis�s et on divise $\alpha$ par 2.
% 
% On voit que la m�thode met toujours longtemps � converger car la
% direction de descente ne suit pas vraiment une direction optimale qui
% serait au centre de la ligne de niveau, c'est � dire la direction
% curviligne qui suivrait le � creux � de la fonction.
% 
% A la place, on oscille autour de cette direction optimale en suivant des
% directions qui ne sont pas optimales (souvent environ � 45� entre la
% direction optimale et sa perpendiculaire).
% 
% Le fait que cette direction ne sont pas optimale fait qu'il est
% impossible d'avancer beaucoup dans cette direction sans faire r�augmenter
% le co�t $J$. Ainsi, le pas ne peux pas vraiment augmenter.
% 
% Ce probl�me de direction vient du fait que le gradient nous donne une
% approximation de premier ordre. On essaye descend donc forc�ment en ligne
% droite ce qui n'est pas optimal.

% initialisation des variables
alpha =  1;
grad = mongradient(theta0);
Jlist = [];
J = moncritere(theta0);
Jprec = J+1e-3;
theta = theta0;
theta_old = theta0;
i = 1;
j = 1;

% initialiser la figure
close all;
init_fig(theta0, Jmat, n, X, Y);

% tant qu'on a pas converg�, on it�re
while norm(grad) > 1e-3 && i < 15000 && j < 10000
    
    % calculs
    grad = mongradient(theta);                  % calcul du gradient
    direction = -grad;                          % direction de descente
    theta_new = theta + alpha * direction;      % MAJ de theta
    J_new = moncritere(theta_new);              % calcul de J
    
    % si on am�liore J avec le calcul r�alis�
    if(J - J_new > 0)
        
        % augmentation de alpha pour l'it�ration suivante
        alpha = alpha*1.3;
        
        % enregistrement de ce qui a �t� fait
        Jprec = J;
        J = J_new;
        Jlist = [Jlist J];
        theta_old = theta;
        theta = theta_new;
        
        % affichage theta
        h = plot([theta_old(1) theta(1)], [theta_old(2) theta(2)], '-ro');
        set(h, 'MarkerSize', 2, 'markerfacecolor', 'r');
        
        j = j + 1;
    
    % sinon si on a augment� J, on enregistre rien et on diminue alpha
    else
        alpha = alpha/2; 
    end
    
    i = i + 1;
end

% theta final
h = plot(theta(1,:), theta(2,:), 'ro');
set(h, 'MarkerSize', 8, 'markerfacecolor', 'r');
text(theta(1,1), theta(2,1)+0.025, ['\theta_{' int2str(j-1) '}'], 'fontsize', 15)
title('Evolution de \theta avec la m�thode 2');

% affichage �volution J
figure;
plot(Jlist);
title('Evolution de J avec la m�thode 2');

%% Trois�me version avec la matrice Hessienne
%
% Cette fois, on calcule la matrice Hessienne afin d'augmenter la vitesse
% de convergence. On calcule donc (via la matrice Hessienne) les d�riv�es
% secondes de la fonction �tudi�e, permettant de converger beaucoup plus
% rapidement.
%
% Le probl�me est que notre matrice Hessienne n'est pas d�finie positive,
% ou du moins pas toujours bien conditionn�e. On utilise donc la m�thode de
% _quasi-Newton_ en utilisant au lieu de la matrice $H$ une matrice $B$
% proche de $H$ mais d�finie positive. Dans notre cas, on se contente de
% reconditionner la matrice $H$ en avant $\lamda = 3$ sur la diagonale.
%
% On remarque qu'avec cette m�thode, on converge beaucoup plus rapidement
% qu'avec les m�thodes pr�c�dentes.

% initialisation des variables
lambda = 3;
Jlist = [];
J = moncritere(theta0);
Jprec = J+1e-3;
grad = mongradient(theta0);
theta = theta0;
i = 1;

% initialiser la figure
close all;
init_fig(theta0, Jmat, n, X, Y);

% tant qu'on a pas converg�, on it�re
while norm(grad) > 1e-3 && i < 3000
%for i=1:2
    % calculs
    grad = mongradient(theta);             % calcul du gradient
    H = monHessien(theta);                 % calcul de la matrice Hesienne
    B = H + lambda * eye(size(H));         % calcul d'une matrice proche de H def pos
    direction = -B\grad;                   % direction de descente
    theta_old = theta;                     % sauvegarde ancien theta
    theta = theta + direction;             % MAJ theta
    
    % calcul de J
    Jprec = J;
    J = moncritere(theta);
    Jlist = [Jlist J];
    
    % trace du theta courant
    h = plot([theta_old(1) theta(1)], [theta_old(2) theta(2)], '-ro');
    set(h, 'MarkerSize', 2, 'markerfacecolor', 'r');
    
    % inc i
    i = i + 1;
end

% theta final
h = plot(theta(1,:), theta(2,:), 'ro');
set(h, 'MarkerSize', 8, 'markerfacecolor', 'r');
text(theta(1,1), theta(2,1)+0.025, ['\theta_{' int2str(i-1) '}'], 'fontsize', 15)
title('Evolution de \theta avec la m�thode 3');

% affichage �volution J
figure;
plot(Jlist);
title('Evolution de J avec la m�thode 3');