#include <iostream>
#include <chrono>


int main() {
    auto lang = "C++";
    std::cout << "Hello and welcome to " << lang << "!\n";

    auto now = std::chrono::system_clock::now();

    for (int i = 1; i <= 5; i++) {
        std::cout << "i = " << i << std::endl;
    }

    return 0;
}