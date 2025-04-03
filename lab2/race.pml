#define NUM_PROCESSES 2

byte counter = 0;
byte progress[NUM_PROCESSES];

proctype incrementer(byte procs_id){
    int tmp;

    tmp = counter;
    counter = tmp + 1;
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