#include "../include/allocator.h"
#include <stdio.h>
#include <string.h>

// Some memory space
#define MEMORY 4096
static uint8_t mem[MEMORY];

int main(void) {
    struct allocator_unit unit = {
        .ptr = mem,
        .size = MEMORY
    };

    allocator_init(&unit);

    // allocate 12 bytes for "Hello world\0"
    char* hello = NULL;

    if( !(hello = allocator_alloc(&unit, 12)) ) {
        printf("12 bytes pointer is NULL\n");
        return 1;
    }

    // else is allocated
    printf("Base: %p\n", mem);
    printf("Addr1: %p\n", hello);

    // move string to `hello`
    strcpy(hello, "Hello World");
    size_t len = strlen(hello);
    printf("Addr1 string length: %u\n", len);

    // allocate some random pointer
    int* ptr;
    if( !(ptr = allocator_alloc(&unit, 90)) ) {
        printf("90 bytes pointer is NULL\n");
        return -1;
    }

    printf("Addr2: %p\n", ptr);

    // write something into the pointer
    *ptr = 10;

    // Now free the pointer
    allocator_free(&unit, ptr);
    // free the first pointer
    allocator_free(&unit, hello);

    // Now assert the header
    uint32_t header = *((uint32_t*)(mem));
    header &= 0x7FFFFFFF;

    if(header == (4092)) {
        printf("SUCCESS\n");
    }else{
        printf("FAILURE: Have %u\n", header);
        return -1;
    }

    int res = allocator_check_free(&unit);
    if(res == 1) {
        printf("UNUSED\n");
    }else{
        printf("FAILURE: USED\n");
        return -1;
    }

    return 0;
}