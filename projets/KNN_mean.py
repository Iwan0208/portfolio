from sklearn.datasets import fetch_openml, load_digits
import numpy as np
import matplotlib.pyplot as plt
import matplotlib    

def init() :
    """
    Initialise les données
    """
    
    # Récupère les images des chiffres et les labels correspondant
    mnist = fetch_openml("mnist_784") 
    mnist.target = mnist.target.astype(np.int8)

    X = np.array(mnist.data)
    Y = np.array(mnist.target)

    return X[:100]


def lis_affiche(liste_moyennes) :
    """
    affiche la liste des points donnée en paramètres avec matplotlib
    """

    # nbr = x
    # nbr correspond aux pixels de  l'image 28x28 = 784 
    plt.axis("off")

    for point in liste_moyennes :
        nbr = np.array(point)
        nbr_image = nbr.reshape(28, 28)
        plt.imshow(nbr_image, cmap=matplotlib.cm.binary)
        plt.show()

def indice_points_random(k : int, X) :
    """
    Récupère et renvoie une liste de K valeurs randoms dans la liste X
    """

    return [np.random.randint(X.shape[0]) for i in range(k)]

def distance(p : int, A : np.ndarray, B : np.ndarray) :
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

def plus_proche(point : np.ndarray, liste_points : list[np.ndarray]) :
    """
    Renvoie l'indice auquel le point donné est le + proche dans la liste de points
    """

    mini = distance(2, point, liste_points[0])
    indice_mini = 0

    for i in range(len(liste_points)) :
        if mini > (dis := distance(2, point, liste_points[i])) :
            indice_mini = i
            mini = dis
    
    return indice_mini

def moyenne(liste_points : list[np.ndarray], X : np.ndarray) :
    """
    Calcule le point moyen d'une liste de points
    """

    nb_points = len(liste_points)
    point_moyenne = []
    for i in range(len(X[liste_points[0]])) :
        somme = 0
        for indice_point in liste_points :
            somme += X[indice_point][i]
        
        point_moyenne.append(somme // nb_points)
    
    return point_moyenne


def main(k) :
    """
    programme principal qui effectue toutes les actions
    renvoie la liste des K points moyens
    """

    print("INITIALISATION")
    X = init()

    print("RECUPERATION DES POINTS")
    x_list = indice_points_random(k, X)
    liste_point = [X[i] for i in x_list]

    ensemble_indices_points = [[x_list[i]] for i in range(k)]

    i = 0

    print("ORGANISATION DES PAQUETS")
    for i in range(len(X)) :
        if i not in x_list :
            ensemble_indices_points[plus_proche(X[i], liste_point)].append(i)
        if i % (len(X) / 10) == 0 :
            print(i * 100 // len(X), '%')
        i+=1

    print("CALCUL DES CENTRES")
    liste_moyennes = [moyenne(paquet, X) for paquet in ensemble_indices_points]

    return liste_moyennes

points = main(2)
lis_affiche(points)
