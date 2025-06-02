#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

#include <time.h>

#define TAILLE_SERPENT_INIITALE 10
#define SCORE_OBJECTIF 10
#define TAILLE_SERPENT_MAX TAILLE_SERPENT_INIITALE + SCORE_OBJECTIF
#define ARRET 'a'

#define CORPS_SERPENT 'X'
#define TETE_SERPENT 'O'
#define CHAR_BORDURE '#'
#define CHAR_PAVE '#'
#define CHAR_VIDE ' '
#define CHAR_POMME '6'

#define MINI_CO_X 1
#define MAXI_CO_X 80
#define MINI_CO_Y 1
#define MAXI_CO_Y 40

#define POSX_DEBUT 40
#define POSY_DEBUT 20

#define INTERVALLE_TMPS_INITIAL 150000 // en micro sec
#define DIMINUTION_TEMPS 99 // en %, diminue de 10% le temps d'intervalle à chaque pomme mangée

#define GAUCHE 'q'
#define DROITE 'd'
#define HAUT 'z'
#define BAS 's'

#define NOMBRE_BLOCS 4
#define TAILLE_BLOC 5


// plateau entier avec les bordures et les blocs
typedef char t_plateau[MAXI_CO_Y][MAXI_CO_X];

// créer le tableau de jeu en variable globale
t_plateau plateauDeJeu;

int tailleSerpent = TAILLE_SERPENT_INIITALE;
int intervalleTemps = INTERVALLE_TMPS_INITIAL;

// créer les bordures et les blocs
void initPlateau(t_plateau);

// test si un bloc a une position correcte par rapport aux bordures et au serpent (pour que le serpent apparaisse dans un bloc)
bool blocPosOK(int posx, int posy);

// test si un bloc a déjà été créé sur ses coordonnées
bool blocDejaCree(int listeBlocs[NOMBRE_BLOCS][2], int nbBlocs, int posx, int posy);

// génère un bloc
void creerBlocs(t_plateau);

// affiche le plateau
void dessinerPlateau(t_plateau);

// place le curseur en position (x, y)
void gotoXY(int x, int y);

// affiche le caractère c en position (x, y)
void afficher(int x, int y, char c);

// affiche le serpent dans le terminal
void dessinerSerpent(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]);

// efface le caractère en position (x, y)
void effacer(int x, int y);

// efface entièrrement le serpent dans le terminal
void effacerSerpent(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]);

// test si le serpent se prend un mur
bool testCollisionMur(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX], t_plateau Plateau);

// test si le serpent se touche
bool testCollisionSerpent(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]);

// déplace le serpent d'une case vers la droite et l'affiche
void progresser(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX], char dir, bool *estMort, bool *pommeMangee);

// créé une pomme sur le plateau de jeu
void ajouterPomme(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]);

// renvoie vrai si une touche est préssée
int kbhit();

// désactive l'affichage des caractères qu'on tape dans le Terminal
void disableEcho();

// réactive cet affichage
void enableEcho();

int main() {
    /*Déclaration des variables*/


    int listeX[TAILLE_SERPENT_MAX];
    int listeY[TAILLE_SERPENT_MAX];
    bool estMort = false;
    int i;

    int touchePressee = 0;
    char carEntre;

    char direction = 'd';

    bool pommeMangee = false;
    
    int intervalleTemps = INTERVALLE_TMPS_INITIAL;
    int score = 0;


    listeX[0] = POSX_DEBUT;
    listeY[0] = POSY_DEBUT;

    /*Code principal*/
    disableEcho();
    srand(time(NULL));

    for (i = 1; i < TAILLE_SERPENT_INIITALE; i++) {
        listeX[i] = listeX[i-1] - 1;
        listeY[i] = listeY[i-1];
    }

    initPlateau(plateauDeJeu);
    dessinerPlateau(plateauDeJeu);
    ajouterPomme(listeX, listeY);

    dessinerSerpent(listeX, listeY);

    while (!(touchePressee) && !(estMort) && (score <= SCORE_OBJECTIF)) {

        progresser(listeX, listeY, direction, &estMort, &pommeMangee);

        if (pommeMangee) {
            ajouterPomme(listeX, listeY);
            pommeMangee = false;
            score++;
            tailleSerpent++;
            intervalleTemps = intervalleTemps * (100 - DIMINUTION_TEMPS) / 100;
        }

        usleep(intervalleTemps);

        if (kbhit()) {
            scanf("%c", &carEntre);
            
            if (carEntre == ARRET) {
                    touchePressee = 1;
            } else if ((carEntre == GAUCHE) && (direction != DROITE)) {
                direction = GAUCHE;
            } else if ((carEntre == DROITE) && (direction != GAUCHE)) {
                    direction = DROITE;
            } else if ((carEntre == HAUT) && (direction != BAS)) {
                    direction = HAUT;
            } else if ((carEntre == BAS) && (direction != HAUT)) {
                    direction = BAS;
            }
        }
    }

    gotoXY(0, 40);
    enableEcho();
    return EXIT_SUCCESS;
}

void initPlateau(t_plateau Plat) {

    int y;
    int x;
    char charXY;

    for (y = MINI_CO_Y; y <= MAXI_CO_Y; y++) {
        for (x = MINI_CO_X; x <= MAXI_CO_X; x++) {
            if ((x == MINI_CO_X) || (x == MAXI_CO_X) || (y == MINI_CO_Y) || (y == MAXI_CO_Y)) {
                charXY = CHAR_BORDURE;
            } else {
                charXY = CHAR_VIDE;
            }

            Plat[y-1][x-1] = charXY;
        }
    }

    // Créé les trous dans les bordures
    Plat[MAXI_CO_Y / 2 -1][MINI_CO_X-1] = CHAR_VIDE;
    Plat[MAXI_CO_Y / 2 -1][MAXI_CO_X-1] = CHAR_VIDE;
    Plat[MINI_CO_Y-1][MAXI_CO_X / 2 -1] = CHAR_VIDE;
    Plat[MAXI_CO_Y-1][MAXI_CO_X / 2 -1] = CHAR_VIDE;

    creerBlocs(Plat);
}

bool blocPosOK(int posx, int posy) {
    bool posOK = true;

    if ((posx >= POSX_DEBUT - tailleSerpent - TAILLE_BLOC) && (posx <= POSX_DEBUT + 1) && (posy >= POSY_DEBUT - TAILLE_BLOC) && (posy <= POSY_DEBUT)) {
        posOK = false;
    }

    return posOK;
}

bool blocDejaCree(int listeBlocs[NOMBRE_BLOCS][2], int nbBlocs, int posx, int posy) {
    bool dejaCree = false;
    int i;

    for (i = 0; i < nbBlocs; i++) {
        if ((posx == listeBlocs[i][0]) && (posy == listeBlocs[i][1])) {
            dejaCree = true;
        }
    }

    return dejaCree;
}

void creerBlocs(t_plateau Plat){
    const int MAX_POSX = MAXI_CO_X - TAILLE_BLOC - 1;
    const int MAX_POSY = MAXI_CO_Y - TAILLE_BLOC - 1;

    int listeBlocs[NOMBRE_BLOCS][2];
    int nbBlocs = 0;
    int i;

    int posx;
    int posy;

    int y;
    int x;

    for (i = 0; i < NOMBRE_BLOCS; i++) {


        posx = POSX_DEBUT;
        posy = POSY_DEBUT;

        while (!(blocPosOK(posx, posy)) || (blocDejaCree(listeBlocs, nbBlocs, posx, posy))) { 
            // Boucle pour tester si le bloc a une position acceptable
            posx = rand() % (MAX_POSX - 2) + 2; // un nombre aléatoire entre 2 et le maximum
            posy = rand() % (MAX_POSY - 2) + 2; // -2 pour laisser un espace entre bordure et pavé de chaque coté
        }
        
        for (y = posy; y < posy + TAILLE_BLOC; y++) { // Boucle pour mettre les # sur le tableau Plateau
            for (x = posx; x < posx + TAILLE_BLOC; x++) {
                Plat[y][x] = CHAR_PAVE;
            }
        }

        listeBlocs[nbBlocs][0] = posy;
        listeBlocs[nbBlocs][1] = posx;
        nbBlocs++;

    }
}

void dessinerPlateau(t_plateau T) {
    int y;
    int x;

    system("clear");

    for (y = MINI_CO_Y; y <= MAXI_CO_Y; y++) {
        for (x = MINI_CO_X; x <= MAXI_CO_X; x++) {
            printf("%c", T[y-1][x-1]);
        }
            printf("\n");
        }
}

void gotoXY(int x, int y) {
    printf("\033[%d;%df", y, x);
}

void afficher(int x, int y, char c) {
    if ((x >= MINI_CO_X && x <= MAXI_CO_X) && (y >= MINI_CO_Y && y <= MAXI_CO_Y)) {
    	gotoXY(x, y);
    	printf("%c", c);
    }
}

void dessinerSerpent(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]) {
    int i;


    for (i = 1; i < tailleSerpent; i=i+1) {
        afficher(lesX[i], lesY[i], CORPS_SERPENT);

    afficher(lesX[0], lesY[0], TETE_SERPENT);

    gotoXY(0, 40);
    fflush(stdout);
    }
}

void effacer(int x, int y) {
    if ((x >= MINI_CO_X && x <= MAXI_CO_X) && (y >= MINI_CO_Y && y <= MAXI_CO_Y)) {
        gotoXY(x, y);
        printf("%c", CHAR_VIDE);
    }
}

void effacerSerpent(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]) {
    int i;
    for (i = 0; i < tailleSerpent; i=i+1) {
        effacer(lesX[i], lesY[i]);
    }
}

bool testCollisionMur(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX], t_plateau Plateau) {
    bool estMort;

    int posx;
    int posy;

    posx = lesX[0] - 1; // -1 car décalage entre la pos du serpent (qui commence par 1) et les coordonnées du tableau (qui commencent à 0)
    posy = lesY[0] - 1;


    if ((Plateau[posy][posx] == CHAR_BORDURE) || (Plateau[posy][posx] == CHAR_PAVE)) {
        estMort = true;
    } else {
        estMort = false;
    }

    return estMort;
}

bool testCollisionSerpent(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]) {
    int i;
    bool estMort = false;

    i = 1;
    while ((i < tailleSerpent) && !(estMort)) {
        if ((lesX[0] == lesX[i]) && (lesY[0] == lesY[i])) {
            estMort = true;
        }
        i++;
    }

    return estMort;
}

void progresser(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX], char dir, bool *estMort, bool *pommeMangee) {
    int i;

    int ancienX;
    int ancienY;
    ancienX = lesX[tailleSerpent-1];
    ancienY = lesY[tailleSerpent-1];

    for (i = tailleSerpent - 1; i > 0; i--) {
        lesX[i] = lesX[i-1];
        lesY[i] = lesY[i-1];
    }

    if (dir == DROITE) {
    	lesX[0] = lesX[0] + 1;
    }
    else if (dir == GAUCHE) {
	lesX[0] = lesX[0] - 1;
    }
    else if (dir == BAS) {
	lesY[0] = lesY[0] + 1;
    }
    else if (dir == HAUT) {
	lesY[0] = lesY[0] - 1;
    }

    // Test si le serpent passe par le trou d'une bordure
    if (lesX[0] == MINI_CO_X-1) { // gauche
        lesX[0] = MAXI_CO_X;
    } else if (lesX[0] == MAXI_CO_X+1) { // droite
        lesX[0] = MINI_CO_X;
    } else if (lesY[0] == MINI_CO_Y-1) { // haut
        lesY[0] = MAXI_CO_Y;
    } else if (lesY[0] == MAXI_CO_Y+1) { // bas
        lesY[0] = MINI_CO_Y;
    }

    if (plateauDeJeu[lesY[0]][lesX[0]] == CHAR_POMME) {
        plateauDeJeu[lesY[0]][lesX[0]] = CHAR_VIDE;
        *pommeMangee = true;
    }

    if (testCollisionMur(lesX, lesY, plateauDeJeu) || testCollisionSerpent(lesX, lesY)) {
        *estMort = true;
    }
    else {
        *estMort = false;
        effacer(ancienX, ancienY);
        dessinerSerpent(lesX, lesY);
    }
}

void ajouterPomme(int lesX[TAILLE_SERPENT_MAX], int lesY[TAILLE_SERPENT_MAX]) {
    int posxPomme;
    int posyPomme;
    bool posPommeOK = false;

    int i;

    while (!posPommeOK) {
        posxPomme = rand() % (MAXI_CO_X);
        posyPomme = rand() % (MAXI_CO_Y);

        posPommeOK = true;

        // test si la pomme arrive sur un pavé ou une bordure
        if ((plateauDeJeu[posyPomme][posxPomme] == CHAR_VIDE)) { 
            // test si la pomme arrive sur le corps du serpent
            for (i=0; i < tailleSerpent; i++) {
                if ((lesX[i] == posxPomme) && (lesY[i] == posyPomme)) {
                    posPommeOK = false;
                }
            }
        } else { // => si le car n'est pas CHAR_VIDE
            posPommeOK = false;
        }
    }

    plateauDeJeu[posyPomme+1][posxPomme+1] = CHAR_POMME;
    afficher(posxPomme+1, posyPomme+1, CHAR_POMME);
}


int kbhit(){
	// la fonction retourne :
	// 1 si un caractere est present
	// 0 si pas de caractere present

	int unCaractere=0;
	struct termios oldt, newt;
	int ch;
	int oldf;

	// mettre le terminal en mode non bloquant
	tcgetattr(STDIN_FILENO, &oldt);
	newt = oldt;
	newt.c_lflag &= ~(ICANON | ECHO);
	tcsetattr(STDIN_FILENO, TCSANOW, &newt);
	oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
	fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

	ch = getchar();

	// restaurer le mode du terminal
	tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
	fcntl(STDIN_FILENO, F_SETFL, oldf);

	if(ch != EOF){
		ungetc(ch, stdin);
		unCaractere=1;
	}
	return unCaractere;
}

void disableEcho() {
    struct termios tty;

    // Obtenir les attributs du terminal
    if (tcgetattr(STDIN_FILENO, &tty) == -1) {
        perror("tcgetattr");
        exit(EXIT_FAILURE);
    }

    // Desactiver le flag ECHO
    tty.c_lflag &= ~ECHO;

    // Appliquer les nouvelles configurations
    if (tcsetattr(STDIN_FILENO, TCSANOW, &tty) == -1) {
        perror("tcsetattr");
        exit(EXIT_FAILURE);
    }
}

void enableEcho() {
    struct termios tty;

    // Obtenir les attributs du terminal
    if (tcgetattr(STDIN_FILENO, &tty) == -1) {
        perror("tcgetattr");
        exit(EXIT_FAILURE);
    }

    // Reactiver le flag ECHO
    tty.c_lflag |= ECHO;

    // Appliquer les nouvelles configurations
    if (tcsetattr(STDIN_FILENO, TCSANOW, &tty) == -1) {
        perror("tcsetattr");
        exit(EXIT_FAILURE);
    }
}
