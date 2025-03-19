#include <iostream>
#include <thread>  // для работы с потоками
#include <mutex>  // для управления доступом к общим ресурсам
#include <condition_variable>  // для условной блокировки потоков

#define UPPER_LIMIT 7

enum MessageType { BC, RC };

struct Message {
  MessageType msg_type;
  int msg_data;
};

class Channel {
private:
    Message message;
    bool ready = false;  // флаг, указывающий, готово ли сообщение к передаче
    std::mutex mtx;  // мьютекс для защиты доступа к общим данным
    std::condition_variable cv;  // условная переменная для ожидания события
    
public:
    void send(const Message& msg) {
        std::unique_lock<std::mutex> lock(mtx);  // блокировка доступа к сообщению с помощью мьютекса
        message = msg;
        ready = true;
        cv.notify_one();  // уведомление ожидающих потоков
    }

    Message receive() {
        std::unique_lock<std::mutex> lock(mtx);  // блокировка доступа к сообщению с помощью мьютекса
        cv.wait(lock, [this] { return ready; });  // ожидание, пока флаг ready не станет true
      
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
        std::thread child_thread(factorial, n - 1, std::ref(child_channel));  // создание дочернего потока
        child_thread.detach(); // запуск дочернего потока

        Message msg = child_channel.receive(); // получение р-та от дочернего потока
        int result = msg.msg_data;

        Message msg_out;
        msg_out.msg_type = RC;
        msg_out.msg_data = n * result;

        parent_channel.send(msg_out);  // отправление итогового сообщения через родительский канал
    }
}

int main() {
    Channel parent_channel;
    std::thread main_thread(factorial, UPPER_LIMIT, std::ref(parent_channel));

    Message factorial_result = parent_channel.receive(); // получение р-та вычисления факториала
    std::cout << UPPER_LIMIT << "! = " << factorial_result.msg_data << std::endl;

    main_thread.join(); // ожидание завершения основного потока
    return 0;
}
