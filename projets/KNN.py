from typing import Literal

def distance(p : int, A : tuple[int], B : tuple[int]) -> float | None :
    """
    Calcule la distance entre 2 points
    p = 1 pour la distance de Manhattan
    p = 2 pour la distance euclidienne
    p = 50 (très grand nombre) pour la distance de Chebyshev

    les points A et B doivent avoir autants de dimensions
    """
    if len(A) != len(B) :
        raise ValueError("Les 2 points doivent avoir autant de dimensions")
    
    else :
        somme = 0

        for i in range(len(A)) :
            a = A[i]
            b = B[i]
            calcul = (abs(a - b)) ** p

            somme += calcul
        
        resultat = somme ** (1/p)

        return resultat

def KNN(point : tuple[int], liste_points : list[tuple[int]], k : int, mode : Literal['classification', 'c', 'regression', 'r'] = 'c') :
    liste_distances : list[tuple[float, int]] = []

    # pour chaque point, calcule la distance avec le point "point", et range le tuple (distance, indice_point) dans une liste
    for num_point in range(len(liste_points)) :
        liste_distances.append((distance(2, point, liste_points[num_point]), num_point))
    
    liste_distances_triee = []

    # trie la liste en fonctions de la distance
    while len(liste_distances) > 0 :
        point_min = liste_distances[0]
        indice_min = 0

        for num_point in range(len(liste_distances)) :
            if liste_distances[num_point][0] < point_min[0] :
                point_min = liste_distances[num_point]
                indice_min = num_point
            
        liste_distances_triee.append(liste_distances.pop(indice_min))
    
    k_points_proches = []
    # récupère les K premiers points de la liste triée
    # donc les K points les + proches
    for i in range(min(k, len(liste_distances_triee))) :
        k_points_proches.append(liste_points[liste_distances_triee[i][1]])
    
    # si le mode est "classification", alors récupère la valeur la + présente
    if mode[0] == 'c' :
        result = plus_present(k_points_proches)
    
    # si le mode est "regression", alors calcule la moyenne des valeurs
    elif mode[0] == 'r' :
        result = moyenne_points(k_points_proches)
    
    return result

def plus_present(liste : list[tuple[int, ...]]) :
    """
    Prend en paramètre une liste de points, et renvoie le point le + fréquent de la liste 
    """

    nb_presences = {}
    # compte les occurences pour chaque valeur
    for i in liste :
        if i in nb_presences :
            nb_presences[i] += 1
        else :
            nb_presences[i] = 1
    
    # trouve l'occurence maximal et renvoie la valeur la + présente
    max_val = 0
    objet_max = None

    for i in nb_presences :
        if nb_presences[i] > max_val :
            max_val = nb_presences[i]
            objet_max = i
    
    return objet_max

def moyenne_points(liste_points : list) :
    """
    Prend en paramètre une liste de points, et renvoie le point moyen
    """

    nb_points = len(liste_points)
    point_moyenne = []

    for i in range(len(liste_points[0])) :
        somme = 0
        for indice_point in range(len(liste_points)) :
            somme += liste_points[indice_point][i]
        
        point_moyenne.append(somme / nb_points)
    
    return tuple(point_moyenne)


points = [(1, 2), (2, 3), (2, 1), (2, 3), (8, 6), (4, 5), (6, 3), (8, 7), (6, 3)]

print(KNN((1, 2), points, 2, 'c'))