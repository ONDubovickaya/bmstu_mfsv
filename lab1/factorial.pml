#define UPPER_LIMIT 7

mtype = { BC, RC };

typedef Message {
    mtype msg_type;
    int msg_data;
};

proctype factorial(int n; chan parent_channel){
    chan child_channel = [1] of { Message };
    Message msg;
    int result;

    if 
    :: (n <= 1) ->
        msg.msg_type = BC;
        msg.msg_data = 1;

        parent_channel ! msg

    :: (n >= 2) ->
        run factorial(n-1, child_channel);
        child_channel ? msg;

        result = msg.msg_data;

        msg.msg_type = RC;
        msg.msg_data = n * result;

        parent_channel ! msg
    fi 
}

init {
    chan child_channel = [1] of { Message };
    Message factorial_result;

    run factorial(UPPER_LIMIT, child_channel);
    child_channel ? factorial_result;
    printf("%d! = %d\n", UPPER_LIMIT, factorial_result.msg_data)
}
