#define spin_lock(mutex) \
    do \
    :: 1 -> atomic { \
        if \
        :: mutex == 0 -> \ 
            mutex = 1 ; \
            break \
        :: else -> skip \
        fi \
    } \
    od

#define spin_unlock(mutex) \
    mutex = 0

#define NUM_PROCESSES 2

byte counter = 0;
byte progress[NUM_PROCESSES];
byte mutex = 0;

proctype incrementer(byte procs_id){
    int tmp;

    spin_lock(mutex);
    tmp = counter;
    counter = tmp + 1;
    spin_unlock(mutex);
    
    progress[procs_id] = 1; 
}

init {
    int i = 0;
    int sum = 0;

    atomic {
        i = 0;
        do 
        :: i < NUM_PROCESSES ->
            progress[i] = 0;
            run incrementer(i);
            i++;
        :: i >= NUM_PROCESSES -> break
        od;
    }

    atomic {
        i = 0;
        sum = 0;
        do
        :: i < NUM_PROCESSES ->
            sum = sum + progress[i];
            i++;
        :: i >= NUM_PROCESSES -> break
        od;
        assert(sum < NUM_PROCESSES || counter == NUM_PROCESSES)
    }
}