#include <stdio.h>

int main(){
    int i = 0;
    char buffer[255];

    printf("input string with blank: ");
    gets(buffer);
    printf("%s\n",buffer);
    while(buffer[i]){
        printf("char[code]: %d[%d]\n", (int)buffer[i], i++);
    }

    printf("\n");
    i = 0;

    printf("input string with blank: ");
    fgets(buffer, 255, stdin);

    printf("%s", buffer);
    while(buffer[i]){
        printf("char[code]: %d[%d]\n", (int)buffer[i], i++);
    }

    return 0;

}
