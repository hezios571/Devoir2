from schedule import Schedule
from solver_naive import solve as naive_solve  
import random


def cost(schedule: Schedule, solution: dict) -> int:
    return schedule.get_n_creneaux(solution)

# Solution initiale un peu plus facile a parcourir pour le solve
def generate_initial_solution(schedule: Schedule) -> dict:
    solution = {}

    
    courses = list(schedule.course_list)
    courses.sort(key=lambda c: len(schedule.get_node_conflicts(c)), reverse=True) # on trie les cours par leur nombre de conflits en decroissant

    for course in courses:
        # on prend le plus petit slot possible 
        slot = 1
        while True:
            conflict_found = False
            for conf in schedule.get_node_conflicts(course):
                if conf in solution and solution[conf] == slot: #on parcours les slot en mode croissant et on verfifie si ya un conflit
                    conflict_found = True
                    break
            if not conflict_found:
                break
            slot += 1
        solution[course] = slot

    schedule.verify_solution(solution)
    return solution

# on diffère de la solution courante en bougeant 1 cours de timeslot
def generate_neighbors(solution: dict, schedule: Schedule) -> list[dict]:
    
    used_slots = set(solution.values())
    max_slot=max(used_slots)

    courses_in_max = [c for c, s in solution.items() if s == max_slot] 
    courses_in_max.sort()  
    course = courses_in_max[0]  #on prend le dernier timeslot (le plus grand)

    current_slot = solution[course]
    

    conflicting_courses = schedule.get_node_conflicts(course) # on verifie les conflits de ce cours

    # On essaie chaque cours et on en prend un qui peut bouger de timeslot
    for course in courses_in_max:
        current_slot = solution[course]
        conflict_courses = schedule.get_node_conflicts(course)
        neighbors = []

        for slot in sorted(used_slots): # on essaie de mettre le cours dans un autre timeslot
            if slot == current_slot:
                continue

            # vérifier s'il y a un conflit dans ce slot
            conflict = False
            for other in conflict_courses:
                if solution[other] == slot:
                    conflict = True
                    break

            if conflict:
                continue

            new_sol = solution.copy()
            new_sol[course] = slot      
            neighbors.append(new_sol)   # retourne les solutions valides

    if neighbors:
            return neighbors
    return []

# Trouve le meilleur prochaine voisin à explorer et retourne celui-ci
def select_neighbor(valid_neighbors: list[dict], schedule: Schedule) -> dict:
    best = None
    best_cost = None
    for n in valid_neighbors: # parcours les voisins et évalue leur nombre de timeslots (cost)
        c = cost(schedule, n)
        if best is None or c < best_cost: # si le voisin courant est meilleur que le précédent, on le garde
            best = n
            best_cost = c
    return best



def solve(schedule: Schedule):
    S = generate_initial_solution(schedule)
    S_best = S.copy()
    best_cost = cost(schedule, S_best)

    max_iter = 10000
    no_improve_limit = 500 
    no_improve = 0


    for _ in range(max_iter):

        neighbors = generate_neighbors(S, schedule)

        if not neighbors: 
            break

        S = select_neighbor(neighbors, schedule)
        current_cost = cost(schedule, S)

        if current_cost < best_cost: #remplace la vieille solution par une à coût moindre
            best_cost = current_cost
            S_best = S.copy()
            no_improve = 0
        else:
            no_improve += 1

        if no_improve > no_improve_limit: #si on a pas improve après 500 itérations on retourne la solution toruvée
            break

    schedule.verify_solution(S_best) #dernière vérification de la solution finale
    
    return S_best
