#ifndef _allocator_included
#define _allocator_included

#include <stdint.h>

/**
 * The structure of an allocation unit (page/memory block).
 */
struct allocator_unit {

    /**
     * The size of the block in bytes.
     */
    uint32_t size;

    /**
     * The pointer to that memory area.
     */
    uint8_t* ptr;
};

/**
 * Allocates in the allocation unit the amount of bytes specified in size.
 * 
 * NOTE: All parameters are unchecked. Please test that nothing is a
 * null pointer.
 * 
 * @param unit The allocation unit
 * @param size The size of the allocation area
 * 
 * @return The pointer by success, else NULL
 */
extern void* allocator_alloc(struct allocator_unit* unit, uint32_t size);

/**
 * Marks the memory area as free, allocated from ptr.
 * 
 * NOTE: All parameters are unchecked. Please test that nothing is a
 * null pointer, and ptr is in the memory block.
 * 
 * @param unit The allocation unit
 * @param ptr The pointer to the memory block
 */
extern void allocator_free(struct allocator_unit* unit, void* ptr);

/**
 * Initializes an memory area.
 * 
 * NOTE: Before allocating something from an allocation unit,
 * initialize it with this function.
 * 
 * Do note that all properies must be set.
 * 
 * @param unit The allocation unit to initialize
 */
extern void allocator_init(struct allocator_unit* unit);

/**
 * Check if allocation unit is used.
 * 
 * @param unit The allocation unit
 * 
 * @return 0 if used, else 1
 */
extern int allocator_check_free(struct allocator_unit* unit);

#endif