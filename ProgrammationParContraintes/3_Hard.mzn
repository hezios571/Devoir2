% NOM_ETUDIANT_1 (MATRICULE_1)
% NOM_ETUDIANT_2 (MATRICULE_2)

include "globals.mzn"; 

%-----------------------------------------------------------------------------% 
% Données
%-----------------------------------------------------------------------------%

int: n;
array[1..n,1..n] of int: distance;
int: min_val = min([distance[i,j] | i,j in 1..n where distance[i,j] > 0]);
int: max_val = max([distance[i,j] | i,j in 1..n]);
array[1..n,1..2] of int: fenetre_arrivee;
int: max_trajet = max([fenetre_arrivee[i,2] | i in 1..n]);
int: max_fenetre = max([fenetre_arrivee[i,2] - fenetre_arrivee[i,1]| i in 2..n]);

%-----------------------------------------------------------------------------% 
% Variables de décisions
%-----------------------------------------------------------------------------%

array[1..n] of var 1..n: chemin_tournee;
array[1..n] of var 1..n: circuit_tournee;
array[1..n] of var 0..max_trajet: cumul_temps;
array[1..n] of var 0..max_fenetre: temps_attente;
var 0..max_trajet: total_temps_attentes = sum(temps_attente);
var int: temps_trajet;

%-----------------------------------------------------------------------------% 
% Partie étudiant
%-----------------------------------------------------------------------------%

constraint chemin_tournee[n] = 1;
constraint all_different([chemin_tournee[k] | k in 1..n-1]);
constraint forall(k in 1..n-1)(chemin_tournee[k] != 1);
constraint circuit_tournee[1] = chemin_tournee[1];
constraint forall(k in 1..n-1)(circuit_tournee[chemin_tournee[k]] = chemin_tournee[k+1]);
constraint circuit(circuit_tournee);
constraint cumul_temps[1] = 0;
constraint temps_attente[1] = 0;
constraint cumul_temps[chemin_tournee[1]] = cumul_temps[1] + temps_attente[1] + distance[1,chemin_tournee[1]];
constraint forall(k in 2..n-1)(
    cumul_temps[chemin_tournee[k]] = cumul_temps[chemin_tournee[k-1]] + temps_attente[chemin_tournee[k-1]] + distance[chemin_tournee[k-1],chemin_tournee[k]]
);
constraint forall(i in 1..n)(
    fenetre_arrivee[i,1] <= cumul_temps[i] /\ cumul_temps[i] <= fenetre_arrivee[i,2]
);
constraint temps_trajet = cumul_temps[chemin_tournee[n-1]] + temps_attente[chemin_tournee[n-1]] + distance[chemin_tournee[n-1],1];

solve minimize temps_trajet;

%-----------------------------------------------------------------------------% 

output [
  "Chemin de la tournée                   : \(chemin_tournee)\n",
  "Circuit de la tournée                  : \(circuit_tournee)\n",
  "Temps cumulés avant d'entrer en ville  : \(cumul_temps)\n",
  "Temps d'attente avant l'entrée en ville: \(temps_attente)\n",
  "Temps d'attente total                  : \(total_temps_attentes)\n",
  "Temps de trajet total                  : \(temps_trajet)\n",
];
