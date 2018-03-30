#include "mouse.hh"
#include <stdlib.h>
#include <iostream>

Mouse::Mouse (std::string name)
    :
    Animal(name)
{
    m_sound = "Squeak!";
}

void randomBlock(int* vec, size_t s)
{
    for(size_t i = 0; i < s; i++)
        vec[i] = rand() % 5; 
}

__global__ void add_vec(int* a, int* b, int* c, size_t size)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    while( tid < size)
    {
        c[tid] = a[tid] + b[tid];
        tid += gridDim.x * blockDim.x;
    }    
}

//capsule to run cuda Kernel 
void runKernel()
{
    size_t s = 100;
    int* a_dev, *b_dev, *c_dev;

    int* a = (int*) malloc(sizeof(int) * s);
    randomBlock(a, s);
    int* b = (int*) malloc(sizeof(int) * s);
    randomBlock(b, s);
    int* c = (int*) malloc(sizeof(int) * s);
    randomBlock(c, s);

    cudaMalloc((void **) &a_dev, sizeof(int) * s);
    cudaMemcpy(a_dev, a, sizeof(int) * s, cudaMemcpyHostToDevice);
    cudaMalloc((void **) &b_dev, sizeof(int) * s);
    cudaMemcpy(b_dev, b, sizeof(int) * s, cudaMemcpyHostToDevice);
    cudaMalloc((void **) &c_dev, sizeof(int) * s);

    add_vec<<<1, 100>>>(a_dev, b_dev, c_dev, s);

    cudaMemcpy(c, c_dev, sizeof(int) * s, cudaMemcpyDeviceToHost);

    std::cout << "My mouse brain does math too: ";
    for(int i = 0; i < 10; i++)
        std::cout << a[i] << " + " << b[i] << " = " << c[i] << "; ";
    std::cout << std::endl;
}

//mouse is also cuda-powered 
void Mouse::talk()
{
    Animal::talk(); //keep up the squeaks
    
    runKernel();
}

