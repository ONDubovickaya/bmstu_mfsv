#include <iostream>

#define UPPER_LIMIT 7

enum MessageType { BC, RC };

struct Message {
    MessageType msg_type;
    int msg_data;
};

Message factorial(int n) {
    if (n <= 1) {
        return {BC, 1}; // базовый случай: 0! и 1! равны 1
        
    } else {
        Message msg = factorial(n - 1); // рекурсивный вызов
        return {RC, n * msg.msg_data}; // возвращаем р-т вычисления факториала
    }
}

int main() {
    Message result = factorial(UPPER_LIMIT);
    std::cout << UPPER_LIMIT << "! = " << result.msg_data << std::endl;
    return 0;
}
