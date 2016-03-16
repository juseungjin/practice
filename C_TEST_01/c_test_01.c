//
// 1. String Analyzer
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALPHA_NUM 26 /* A~Z */
#define MAX_STR_LEN 200
#define MAX_WORD_COUNT 32

int is_valid_string(char* p_str);
char get_highfreq_letter(char* p_str);
int get_word_count(char *p_str);
void to_uppercase(char* p_src, char* p_dest);

int main(void)
{
    char ch;
    char buffer[MAX_STR_LEN];
    char p_uppercase[MAX_STR_LEN];
    int word_num;

    while (1)
    {
        printf("> Enter string : ");
        gets(buffer);

        if (is_valid_string(buffer))
            break;

        printf(":: Please type alphabet only!\n\n");
    }

    ch = get_highfreq_letter(buffer);
    printf("\n> The alphabet of the highest frequency : %c\n", ch);

    word_num = get_word_count(buffer);
    printf("> The number of words : %d\n", word_num);

    system("pause");
    return 0;
}

// Desc : Checking the string contains invalid character
// Param : p_str - string to check
// Return : 1 if the string does not contain invalid character, 0 otherwise
int is_valid_string(char* p_str)
{
        // TODO: Write code here
    while(*p_str){
        if ((*p_str >= 'a' && *p_str <= 'z') || (*p_str >= 'A' && *p_str <= 'Z') || *p_str == ' '){
            p_str++;
        } else {
            return 0;
        }
    }
    return 1;
}

// Desc : Getting the most frequently used letter in string
// Param : p_str - string
// Return : The most frequently used letter
char get_highfreq_letter(char* p_str)
{

    // TODO: Write code here
    int max = 0;
    int alpha[ALPHA_NUM] = {0,};
    int i =0;

    char * p_upperstr = (char *) malloc(sizeof(char) * MAX_STR_LEN);

    to_uppercase(p_str, p_upperstr);

    while (*p_upperstr){
        char i = *p_upperstr - 'A';
        alpha[i] += 1;
        p_upperstr++;
    }
    for (i = 1; i < ALPHA_NUM ; i++){
        if ( alpha[i] > alpha[max] )
           max = i;
    }
    return max + 'A';
}

// Desc : Convert a string to uppercase
// Param : p_src - source string, p_dest - coverted string
// Return : None
void to_uppercase(char* p_src, char* p_dest)
{

    // TODO: Write code here
    int diff = 'a' - 'A';
    while (*p_src){
        if (*p_src >= 'a' && *p_src <= 'z')
            *p_dest = *p_src - diff;
        else
        	* p_dest = *p_src;
        p_src++;
        p_dest++;
    }
    *p_dest = '\0';
}

// Desc : Duplication checking the string exists in string array
// Param : wp - string array, str - string to check
// Return : 1 if the str exists in wp, 0 otherwise
int dup_word(char **wp, char *str)
{


    // TODO: Write code here


    return 0;
}

// Desc : Getting the number of word in string
// Param : p_str - string
// Return : the number of unduplicated word in case-insensitively
int get_word_count(char *p_str)
{
  int cnt = 0;
  // TODO: Write code here
  char *token = NULL;
  char *tokenList[MAX_WORD_COUNT] = {NULL,};
  int i, len;

  token = strtok(p_str, " ");

  while (token != NULL){
    // check duplicate
    for (i =0 ; i< cnt ; i++){
        if (!(strcmp(token, tokenList[i])))
            break;
    }

    // add tokenLit
    if (i == cnt){
        len = strlen(token);
        tokenList[cnt] = (char *)malloc((len + 1 )*sizeof(char));
        memset(tokenList[cnt], 0x00, len + 1);
        strcpy(tokenList[cnt], token);
        cnt++;
    }
    token = strtok(NULL, " ");
  }

  for (i=0; i<cnt; i++){
    if (tokenList[i] != NULL)
        free(tokenList[i]);
  }

/*  char seps[] = " \r\n";
  char *token = NULL;
  char *tokenList[32 + 1] = { NULL, };
  int i, len;

  token = strtok (p_str, seps);
  while ((token != NULL) && (cnt <= 32))
  {
    for (i = 0; i < cnt; i++)
    {
      if (!strcmp (token, *(tokenList + i)))
      {
        // duplicated word
        break;
      }
    }
    if (i == cnt)
    {
      // No duplicated words
      len = strlen (token);
      tokenList[cnt] = (char *)malloc (len + 1);
      memset (tokenList[cnt], 0x00, len + 1);
      strcpy (tokenList[cnt], token);
      // update cnt
      cnt++;
    }
    token = strtok (NULL, seps);
  }
  // free
  for (i = 0; i < cnt; i++)
  {
    if (tokenList[i] != NULL)
    {
      free (tokenList[i]);
    }
  }
*/
  return cnt;
}

