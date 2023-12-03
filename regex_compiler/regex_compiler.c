#ifdef ONIG_ESCAPE_UCHAR_COLLISION
#undef ONIG_ESCAPE_UCHAR_COLLISION
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// #include "/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/re_compile/lib/include/oniguruma.h"
// #include "/home/jiaqil6/Vitis_Libraries/data_analytics/L1/include/sw/xf_data_analytics/text/xf_re_compile.h"
// #include "/home/jiaqil6/Vitis_Libraries/data_analytics/L1/src/sw/xf_re_compile.c"
#include "oniguruma.h"
#include "xf_data_analytics/text/xf_re_compile.h"

#define BIT_SET_SIZE (1024)     // max supported size of the bit map for op cclass
#define INSTRUC_SIZE (32768)    // max supported size of the instruction table
#define MESSAGE_SIZE (2048 / 8) // max supported length of the input string
#define CAP_GRP_SIZE (256)      // max supported size of the capturing groups
#define STACK_SIZE (16384)      // max supported internal stack for backtracking

#define MAX_LINES 512  // Maximum number of lines
#define MAX_LINE_LENGTH 128  // Maximum length of each line


// bit set map for op cclass
unsigned int bitset_all[MAX_LINES][BIT_SET_SIZE];
unsigned int bitset[BIT_SET_SIZE];
// instruction list
uint64_t instr_buff_all[MAX_LINES][INSTRUC_SIZE];
uint64_t instr_buff[INSTRUC_SIZE];

unsigned int instr_num_all[MAX_LINES];
unsigned int cclass_num_all[MAX_LINES];
unsigned int cpgp_num_all[MAX_LINES];


int main(int argc, char** argv) {

    int r;

    // ==== read patterns from file
    char *patterns[MAX_LINES];
    unsigned int num_patterns;

    char buffer[MAX_LINE_LENGTH];
    int lineCount = 0;

    FILE *file;
    file = fopen("/home/jiaqil6/Vitis_Libraries/data_analytics/L1/tests/text/regex_vm/patterns.txt", "r");
    if (file == NULL) {
        printf("Error opening file");
        return 1;
    }

    while (fgets(buffer, MAX_LINE_LENGTH, file) != NULL && lineCount < MAX_LINES) {
        buffer[strcspn(buffer, "\n")] = '\0';
        // Allocate memory for the line
        patterns[lineCount] = (char*)malloc(strlen(buffer) + 1);
        if (patterns[lineCount] == NULL) {
            printf("Memory allocation failed");
            return 1;
        }
        // Copy the line
        strcpy(patterns[lineCount], buffer);
        lineCount++;
    }

    num_patterns = lineCount;

    fclose(file);


    // ===== prepare to call compiler
    unsigned int instr_num = 0;
    unsigned int cclass_num = 0;
    unsigned int cpgp_num = 0;


    // compile patterns to Regex instructions
    for (int i = 0; i < num_patterns; ++i) {
        r = xf_re_compile(patterns[i], bitset, instr_buff, &instr_num, &cclass_num, &cpgp_num, NULL, NULL);
        if (r != XF_UNSUPPORTED_OPCODE && r == ONIG_NORMAL) {
            // save instructions for acceleration
            memcpy(instr_buff_all[i], instr_buff, sizeof(instr_buff));
            memcpy(bitset_all[i], bitset, sizeof(bitset));
            instr_num_all[i] = instr_num;
            cclass_num_all[i] = cclass_num;
            cpgp_num_all[i] = cpgp_num;
        }
    }

    // Print intructions
    for (int i = 0; i < num_patterns; ++i) {
        printf("==== Pattern %d ====\n", i);
        printf("Regex pattern is '%s'\n", patterns[i]);
        printf("Number of instructions: %d\n", instr_num_all[i]);

        for (int j = 0; j < instr_num_all[i]; ++j) {
            printf("Insruction: %jd\n", instr_buff_all[i][j]);
        }
    }



    // Print the patterns
    for (int i = 0; i < lineCount; i++) {
        free(patterns[i]);
    }

    return 0;
}
