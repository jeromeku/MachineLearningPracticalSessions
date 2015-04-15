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
n = 75;
[X, Y] = meshgrid(linspace(-1.5, 0.5, n), linspace(-0.5, 0.5, n));
ptx = reshape(X, n*n,1);
pty = reshape(Y, n*n,1);
pt = [ptx pty];

% Define the function J = f(\theta)
Jmat = exp(-0.1)*(exp(pt*a) + exp(pt*b) + exp(pt*c));

% solution initiale
theta0 = [-1.45; -0.45];

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

% pas alpha fix�
alpha =  0.05;

% variables pour la boucle et initialisation
Jlist = [];
J = moncritere(a, b, c, theta0);
Jprec = J + 1;
theta_old = theta0;
theta = theta0;
i = 1;

% initialiser la figure
init_fig(theta0, Jmat, n, X, Y);

% tant qu'on a pas converg�, on it�re
while abs(J - Jprec) > 1e-5 && i < 200
    
    % calculs du nouveau theta
    grad = mongradient(a, b, c, theta);     % calcul du gradient
    direction = -grad;                      % direction de descente
    theta_old = theta;                      % sauvegarde ancien theta pour affichage
    theta = theta + alpha * direction;      % MAJ du point en cours
    
    % trace du theta courant
    h = plot([theta_old(1) theta(1)], [theta_old(2) theta(2)], '-ro');
    set(h, 'MarkerSize', 2, 'markerfacecolor', 'r');
    
    % calcul de J
    Jprec = J;
    J = moncritere(a, b, c, theta);
    Jlist = [Jlist J];
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
% On constate que cette m�thode permet de converger beaucoup plus
% rapidement en nous permettant de partir avec un $\alpha$ relativement
% grand sans avoir peur de diverger.

% initialisation des variables
alpha =  1;
Jlist = [];
J = moncritere(a, b, c, theta0);
Jprec = J+1e-3;
theta = theta0;
theta_old = theta0;
i = 1;
j = 1;

% initialiser la figure
init_fig(theta0, Jmat, n, X, Y);

% tant qu'on a pas converg�, on it�re
while abs(J - Jprec) > 1e-5 && i < 300 && j < 300
    
    % calculs
    grad = mongradient(a, b, c, theta);         % calcul du gradient
    direction = -grad;                          % direction de descente
    theta_new = theta + alpha * direction;      % MAJ de theta
    
    J_new = moncritere(a, b, c, theta_new);     % calcul de J
    
    % si on am�liore J avec le calcul r�alis�
    if(J - J_new > 0)
        
        % augmentation de alpha pour l'it�ration suivante
        alpha = alpha*1.15;
        
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

% initialisation des variables
Jlist = [];
J = moncritere(a, b, c, theta0);
Jprec = J+1e-3;
theta = theta0;
i = 1;

% initialiser la figure
init_fig(theta0, Jmat, n, X, Y);

% tant qu'on a pas converg�, on it�re
while abs(J - Jprec) > 1e-5 && i < 200
    
    % calculs
    grad = mongradient(a, b, c, theta);    % calcul du gradient
    H = monHessien(a, b, c, theta);        % calcul de la matrice Hesienne
    direction = -H\grad;                   % direction de descente
    theta_old = theta;                     % sauvegarde ancien theta
    theta = theta + direction;             % MAJ theta
    
    % calcul de J
    Jprec = J;
    J = moncritere(a, b, c, theta);
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