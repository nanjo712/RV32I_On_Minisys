#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if(argc != 3) {
        printf("Usage: %s <input> <output>\n", argv[0]);
        return 1;
    }
    FILE *in = fopen(argv[1], "rb");
    if(in == NULL) {
        printf("Error: Cannot open file %s\n", argv[1]);
        return 1;
    }
    FILE *out = fopen(argv[2], "w");
    if(out == NULL) {
        printf("Error: Cannot open file %s\n", argv[2]);
        return 1;
    }
    fprintf(out, "memory_initialization_radix=16;\nmemory_initialization_vector=\n");
    // 数据宽度32位
    unsigned int data;
    while(fread(&data, sizeof(unsigned int), 1, in) == 1) {
        fprintf(out, "%08x,\n", data);
    }
    // 去除最后一个逗号
    fseek(out, -2, SEEK_CUR);
    fprintf(out, ";\n");
    fclose(in);
    fclose(out);
    return 0;
}