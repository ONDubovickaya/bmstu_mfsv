#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>

#define UPPER_LIMIT 7

enum MessageType { BC, RC };

struct Message {
  MessageType msg_type;
  int msg_data;
};

class Channel {
private:
    Message message;
    bool ready = false;
    std::mutex mtx;
    std::condition_variable cv;
    
public:
    void send(const Message& msg) {
        std::unique_lock<std::mutex> lock(mtx);
        message = msg;
        ready = true;
        cv.notify_one();
    }

    Message receive() {
        std::unique_lock<std::mutex> lock(mtx);
        cv.wait(lock, [this] { return ready; });
        ready = false;
        return message;
    }
};

void factorial(int n, Channel& parent_channel) {
    Channel child_channel;

    if (n <= 1) {
        Message msg;
        msg.msg_type = BC;
        msg.msg_data = 1;
        parent_channel.send(msg);
        
    } else {
        std::thread child_thread(factorial, n - 1, std::ref(child_channel));
        child_thread.detach(); // Запускаем дочерний поток

        Message msg = child_channel.receive(); // Получаем результат от дочернего потока
        int result = msg.msg_data;

        Message msg_out;
        msg_out.msg_type = RC;
        msg_out.msg_data = n * result;

        parent_channel.send(msg_out);
    }
}

int main() {
    Channel parent_channel;
    std::thread main_thread(factorial, UPPER_LIMIT, std::ref(parent_channel));

    Message factorial_result = parent_channel.receive(); // Получаем результат
    std::cout << UPPER_LIMIT << "! = " << factorial_result.msg_data << std::endl;

    main_thread.join(); // Ждем завершения основного потока
    return 0;
}