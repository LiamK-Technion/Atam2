#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
    asm volatile("sidt %0"
                :"=m" (*idtr)
                :
                :
    );
}

void my_load_idt(struct desc_ptr *idtr) {
    asm volatile("lidt %0"
                :
                :"m" (*idtr)
                :
    );
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
    unsigned short low=addr;
    unsigned short middle=addr>>16;
    unsigned int high=addr>>32;

    gate->offset_low=low;
    gate->offset_middle=middle;
    gate->offset_high=high;
}

unsigned long my_get_gate_offset(gate_desc *gate) {
    unsigned long low, middle, high, result=0;
    low=gate->offset_low;
    low=low & (0xffff);

    middle=gate->offset_middle;
    middle=middle & (0xffff);

    high=gate->offset_high;
    high=high & (0xffffffff);

    middle=middle<<16;
    high=high<<32;

    result=low+middle+high;
    return result;
}
