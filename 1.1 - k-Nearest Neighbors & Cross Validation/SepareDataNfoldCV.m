
function [xapp, yapp, xtest, ytest, indices] = SepareDataNfoldCV(x, y, Nfold, NumFold);
%% G�n�rer les donn�es app et test pour Nfold-CV
%% Valable pour N classes
%% x : donn�es
%% y : labels
%% Nfold : nombre de d�coupage
%% NumFold : num�ro de la portion � prendre pour les donn�es de test
%% G2 - F�vrier 2006

if NumFold > Nfold
    error('Num Portion sup � Nfold')
end

classcode = unique(y);
Nbclasse = length(classcode);

IndApp = [];
IndTest = [];
for i=1:Nbclasse
    Indclass_i = find(y==classcode(i));
    N_i = length(Indclass_i);
    LongPortion_i = round(N_i/Nfold); %% longueur de chaque portion
    IndTestClass_i = Indclass_i( LongPortion_i*(NumFold-1) + 1 : min(LongPortion_i*NumFold, N_i) );
    IndTest = [IndTest; IndTestClass_i];
    IndAppClass_i = setdiff(Indclass_i, IndTestClass_i);
    IndApp = [IndApp; IndAppClass_i];
end
xapp  = x(IndApp, :);   yapp = y(IndApp);
xtest = x(IndTest, :);  ytest = y(IndTest);
indices.app = IndApp;
indices.test = IndTest;
