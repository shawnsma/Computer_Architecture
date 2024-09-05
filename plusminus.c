#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int maxchar = 64;

typedef struct PlayerNode{
    char name[64];
    int plusminus;
    struct PlayerNode *next;
} PlayerNode;

PlayerNode* createNode(const char* name, int scored, int against){
    PlayerNode* newNode = (PlayerNode*)malloc(sizeof(PlayerNode));
    if (newNode == NULL) {
        perror("Error allocating memory for new player node");
        return NULL;
    }
    strcpy(newNode -> name, name);
    newNode -> plusminus = (scored - against);
    newNode -> next = NULL;
    return newNode;
}

PlayerNode* readfile(const char* filename){
    FILE* file = fopen(filename, "r");
    if (file == NULL){
        perror("ERROR FILE DOES NOT EXIST");
        return NULL;
    }

    PlayerNode *head = NULL, *tail = NULL;
    char name[maxchar];
    int scored, against;

    while (fscanf(file, "%63s %d %d", name, &scored, &against) == 3){
        if (strcmp(name, "DONE") == 0){
            break;
        }
        PlayerNode* AnotherNode = createNode(name, scored, against);
        if (!AnotherNode){
            while (head != NULL){
            PlayerNode* temp = head;
            head = head -> next;
            free(temp);
            }
            fclose(file);
            return NULL;
        }
        if (!head){
            head = tail = AnotherNode;
        }
        else{
            tail -> next = AnotherNode;
            tail = AnotherNode;
        }
    }
    fclose(file);
    return head;
}

PlayerNode* actualsort(PlayerNode* sorteded, PlayerNode* current){
    if (sorteded == NULL || (current -> plusminus) > (sorteded -> plusminus) || 
            ((current -> plusminus) == (sorteded -> plusminus) && strcmp(current -> name, sorteded -> name) < 0)){
        current -> next = sorteded;
        return current;
    }

    PlayerNode* tracking = sorteded;
    while (tracking -> next != NULL && ((current -> plusminus < tracking -> next -> plusminus) || 
            (current -> plusminus == tracking -> next -> plusminus && strcmp(current -> name, tracking -> next -> name) >= 0))){
        tracking  =  tracking -> next;
    }
        current -> next = tracking -> next;
        tracking -> next = current;
        return sorteded;
}

PlayerNode* sorted(PlayerNode* head){
    PlayerNode* sorteded = NULL;
    PlayerNode* current = head;
    while (current != NULL){
        PlayerNode* next = current -> next;
        current->next = NULL;
        sorteded = actualsort(sorteded, current);
        current = next;
    }
    return sorteded;
}

int main(int argc, char* argv[]){

    if (argc < 2) {
        perror("ERROR IN INPUT");
        return EXIT_FAILURE;
    }

    PlayerNode* player = readfile((argv[1]));
    if (player == NULL){
        return EXIT_FAILURE;
    }

    player = sorted(player);

    for (PlayerNode* current = player; current != NULL; current = current -> next){
        printf("%s %d \n", current -> name, current -> plusminus);
    }

    while (player != NULL) {
        PlayerNode* temp = player;
        player = player->next;
        free(temp);
    }

    return EXIT_SUCCESS;
}