%% Question 1
%
% CVX est une biblioth�que de calcul matlab permettant de r�soudre des
% probl�mes d'optimisation sous contraintes par une m�thode it�rative.
%
% On teste d'abord CVX sur un probl�me simple de minimisation sous
% contraintes.
%
% On donne a CVX la variable � optimiser ($\theta \in \mathbb{R}^{2}$) en
% minimisant la fonction objectif ($\theta^\top P\theta + \theta^\top q$)
% et en respectant les contraintes ($\theta \leq l$ et $\theta\geq u$).
%
% CVX calcule ensuite la solution optimale par une m�thode it�rative.
%
% La solution obtenue semble bien �tre le minimum delimit� par les
% contraintes.

clear all
close all
clc

% Trac� de la fonction objectif et de 
N = 150;
x = linspace(-5, 10, N);
y = linspace(-5, 6, N);
[X,Y] = meshgrid(x, y);
x = reshape(X,N*N,1);
y = reshape(Y,N*N,1);
J = x.^2 + 2*y.^2 +2*x.*y - x + 2*y;
[c, h]=contour(X, Y, reshape(J, N,N), [-0.5   2 4:4:40], 'linewidth', 1.25);
%clabel(c,h);
hold on

ineq1 = (-4 <= x) & (x <=-1);
ineq2 = (-3 <= y) & (y <= 4);
ineq = ineq1 & ineq2;
hold on
[c,h]=contour(X, Y, reshape(ineq, N,N), [0 0], 'b', 'linewidth', 2);
set(gca,'fontsize', 24)
legend('J(\theta) = c', 'Contrainte', 'fontsize', 14)

% Resolution du probleme par cvx
% param�tre du probl�me
P=[1 1;1 2];
q = [-1; 2];
l = [-4;-3];
u = [-1; 4];

% Probleme
% minimize    1/2 theta'*P*theta + q'*theta
%               s.t.    l_i <= theta_i <= u_i

n = size(P, 1); % nombre de variables
fprintf( 'Calcul de la solution par CVX ... \n\n');

cvx_begin
    cvx_precision best
    
    variable theta(n); % declarer que theta est la variable du prob, vecteur de taille n
    
    minimize ( quad_form(theta,P) + q'*theta) % fonction objectif
    
    subject to
    
        theta >= l; % contraintes 1 (bornes inf)
        theta <= u; % contraintes 2 (bornes sup)
cvx_end

fprintf('\n\n Fait ! \n');

% affichage resultats
fprintf('\n\n Solution obtenue : \n');
disp(theta);

% trace de la solution du probleme
plot(theta(1), theta(2), 'p', 'markersize', 18, 'markeredgecolor', 'g', 'markerfacecolor', 'g')

%% Question 2
%
% On r�soud d�sormais notre probl�me d'optimisation gr�ce � CVX en passant
% par le probl�me dual, plus simple � exprimer.
% 
% Les calculs pr�paratoires ont permis de trouver le lien direct entre la
% solution du probl�me dual et la solution du probl�me primal. (En
% l'occurence, $z = \mu^\top X$.
%
% Notons que gr�ce aux variables duales du probl�me dual, on peut retomber
% sur le probl�me primal et trouver directement le rayon maximum,
% que l'on peut v�rifier en tran�ant un cercle de ce rayon autour de la
% caserne.

load maisons.mat

figure;
dots = plot(X(:,1), X(:,2), 'bs');
hold on;
set(dots(1),'MarkerFaceColor','red', 'markersize', 10);

% donn�es
n = size(X,1);
H = X*X';
q = diag(H);

% minimisation
cvx_begin
    cvx_precision best
    
    variable('m(n)'); % declarer que theta est la variable du prob, vecteur de taille n
    
    dual variables de di;
    
    minimize ( m'*H*m - m'*q) % fonction objectif
    
    subject to
        di : m >= 0;
        de : sum(m) == 1;
    
        %theta >= l; % contraintes 1 (bornes inf)
        %theta <= u; % contraintes 2 (bornes sup)
cvx_end

% solution

z = m'*X;

plot(z(1), z(2), 'p', 'markersize', 18, 'markeredgecolor', 'g', 'markerfacecolor', 'g');

% rayon max

R = sqrt(abs(de) + z*z');
t = 0:0.01:2*pi;
plot(z(1)+cos(t)*R, z(2)+sin(t)*R, '-b');
