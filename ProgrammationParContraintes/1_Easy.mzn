% NOM_ETUDIANT_1 (MATRICULE_1)
% NOM_ETUDIANT_2 (MATRICULE_2)

include "globals.mzn";

%-----------------------------------------------------------------------------%
% Données
%-----------------------------------------------------------------------------%

% Nombre d'acteurs et de rôles
int: n;
% Couleurs des costumes
enum costumes; 
% Costume démandé pour un rôle i (première dimension) par un acteur j (seconde dimension)
array[1..n,1..n] of costumes: choix_costume;

%-----------------------------------------------------------------------------%
% Variables de décisions
%-----------------------------------------------------------------------------%

% Variables de décision pour assigner un acteur à un rôle
array [1..n] of var 1..n: assignation_role;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%

% Il faudrait que tous les roles assignes sont differents
constraint all_different(assignation_role);

% Les acteurs assignes dans des roles differents peut pas avoir meme costume
constraint forall(i,j in 1..n where i<j)(choix_costume[assignation_role[i],i] != choix_costume[assignation_role[j],j]);

% Regle le probleme des acteurs voisins, selon l'ordre lexicographique, ne jouent pas un role adjacent
constraint forall(i in 1..n-1)(abs(assignation_role[i] - assignation_role[i+1]) >1);
%-----------------------------------------------------------------------------%

output	
  ["L'acteur " ++ format(i) ++ 
   " prendra le rôle " ++ format(fix(assignation_role[i])) ++ 
   " (costume " ++ format(choix_costume[fix(assignation_role[i]), i]) ++ ")" ++"\n" 
  | i in 1..n];