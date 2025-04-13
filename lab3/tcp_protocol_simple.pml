#define TOTAL_CHUNKS 3

mtype = { SYN, SYN_ACK, ACK, DATA, FIN, FIN_ACK }

typedef Message {
    mtype msg_type;
    byte payload;
};

chan client_to_server = [1] of { Message };
chan server_to_client = [1] of { Message };

proctype client(){
    Message msg;
    msg.msg_type = SYN;
    msg.payload = 0;

    printf("[client] Sending SYN to server..\n");
    client_to_server ! msg;

    atomic {
        server_to_client ? msg;
        assert(msg.msg_type == SYN_ACK);
        printf("[client] Received SYN_ACK from server\n");
    }

    msg.msg_type = ACK;
    msg.payload = 0;

    printf("[client] Sending ACK to server..\n");
    client_to_server ! msg;

    int i;
    for (i : 1 .. TOTAL_CHUNKS) {
        msg.msg_type = DATA;
        msg.payload = i;

        printf("[client] Sending DATA (payload=%d) to server..\n", msg.payload);
        client_to_server ! msg;

        atomic {
            server_to_client ? msg;
            assert(msg.msg_type == ACK);
            printf("[client] Received ACK for DATA from server\n");
        }
    }

    msg.msg_type = FIN;
    msg.payload = 0;

    printf("[client] Sending FIN to server..\n");
    client_to_server ! msg;

    atomic {
        server_to_client ? msg;
        assert(msg.msg_type == FIN_ACK);
        printf("[client] Received FIN_ACK from server\n");
    }

    msg.msg_type = ACK;
    msg.payload = 0;

    printf("[client] Sending ACK to server..\n");
    client_to_server ! msg;

}

proctype server(){
    Message msg;
    atomic {
        client_to_server ? msg;
        assert(msg.msg_type == SYN);
        printf("[server] Received SYN from client\n");
    }

    msg.msg_type = SYN_ACK;
    msg.payload = 0;

    printf("[server] Sending SYN_ACK to client..\n");
    server_to_client ! msg;

    atomic {
        client_to_server ? msg;
        assert(msg.msg_type == ACK);
        printf("[server] Received ACK from client\n");
    }

    int i;
    for (i : 1 .. TOTAL_CHUNKS) {
        atomic {
            client_to_server ? msg;
            assert(msg.msg_type == DATA);
            printf("[server] Received DATA from client: %d\n", msg.payload);
        }

        msg.msg_type = ACK;
        msg.payload = 0;

        printf("[server] Sending ACK for DATA to client..\n");
        server_to_client ! msg;
    }

    atomic {
        client_to_server ? msg;
        assert(msg.msg_type == FIN);
        printf("[server] Received FIN from client\n");
    }

    msg.msg_type = FIN_ACK;
    msg.payload = 0;

    printf("[server] Sending FIN_ACK to client..\n");
    server_to_client ! msg;

    atomic {
        client_to_server ? msg;
        assert(msg.msg_type == ACK);
        printf("[server] Received ACK from client\n");
    }
}

init {
    run client();
    run server();
}
