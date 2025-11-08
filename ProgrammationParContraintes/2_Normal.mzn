% Jérôme Solis-Bergeron (2137094)
% Reagan Li (2055734)

include "globals.mzn"; 

%-----------------------------------------------------------------------------%
% Données
%-----------------------------------------------------------------------------%

% Nombre de tâches
int: n;
% Durée maximal du projet
int: m;
% Limite de ressources pouvant être partagées entre les tâches en cours
int: limite;

% Durée des tâches
array[1..n] of 1..m: duree_tache;
% Ressources requises par les tâches
array[1..n] of 1..m: ressource_tache;

%-----------------------------------------------------------------------------%
% Variables de décisions
%-----------------------------------------------------------------------------%

array[1..n] of var 1..m: debut_tache; % Début des tâches
array[1..n] of var 1..m: fin_tache; % Fin des tâches

%-----------------------------------------------------------------------------%
% Objectif
%-----------------------------------------------------------------------------%

% Fin du projet
var int: fin_projet;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%

constraint forall(i in 1..n)(fin_tache[i] = debut_tache[i]+duree_tache[i]);
constraint maximum(fin_projet, fin_tache);

% Limite d'energie a respecter en tout temps
constraint cumulative(debut_tache, duree_tache, ressource_tache, limite);

% Assure que pas plus de deux taches ne demarrent en meme temps
constraint forall(t in 1..m)(sum(i in 1..n)(debut_tache[i] = t)<=2);

% Minimuse le temps avant la fin du projet
solve minimize fin_projet;

%-----------------------------------------------------------------------------%

output [
  "Envergure du projet  : ", show(fin_projet), "\n",
  "Début des tâches     : ", show(debut_tache), "\n",
  "Fin des tâches       : ", show(fin_tache), "\n",
];