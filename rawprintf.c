// start isnt called as a function, its called as a literal entry point
// this means this is ran at the os level without, not the program level
// it is a kernel jump, not a function itself. the execve looks for start
// => you can put whatever in here and it wont crash whatsoever
void _start(void) {
  const char msg[] = "Hello, World!";

  __asm__ volatile (   // this is volatile memory, trust i know what im doing
                       // please dont touch it or optimise it
    "mov $1, %%rax\n"  // syscall: 1 = sys_write
    "mov $1, %%rdi\n"  // fd: 1 = stdout
                       // if you change it to $2 it writes to stderr
                       // it will still appear on the output
                       // however it wont appear if you do ./$@ > file
    "lea %0, %%rsi\n"  // pointer to buffer first argument
    "mov %1, %%rdx\n"  // length (formerly $14)
    "syscall\n"        // execute
    :                                 // output: operands asm -> c
    : "m"(msg), "i"(sizeof(msg) - 1)  // input: operands  c -> asm
                                      // m: memory address
                                      // i: immediate constant
                                      // if you change "i":
                                      // you can cut it off
                                      // read instructions
                                      // do crazy stuff with the memory
    : "%rax", "%rdi", "%rsi", "%rdx"  // clobbers: which registers are modified
  );

  __asm__ volatile (
    "mov $60, %%rax\n"    // syscall: 60 = sys_write
    "xor %%rdi, %%rdi\n"  // set rdi to 0 (you can do 'mov $0 %%rdi' too)
    "syscall\n"           // execute
    : // you need %% if you add a colon (variable expansion), else % works
  );
}
