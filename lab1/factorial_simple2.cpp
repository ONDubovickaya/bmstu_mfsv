#include <iostream>

#define UPPER_LIMIT 7

int factorial(int n) {
    if (n <= 1) {
        return 1; // базовый случай: 0! и 1! равны 1
        
    } else {
        int result = factorial(n - 1); // рекурсивный вызов
        return n * result; // возвращаем результат
    }
}

int main() {
    int result = factorial(UPPER_LIMIT);
    std::cout << UPPER_LIMIT << "! = " << result << std::endl;
    return 0;
}