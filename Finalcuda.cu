%%cu
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define N 3
#define blocksize 3

float U[N*N],R[N*N],M[N*N],E[N*N],B[N*N],C[N*N],Final[N*N];
float Rinv[N*N],Uinv[N*N],REC[N*N];


__global__ void matCopy(float*a, float*b)        //Copies second matrix to first matrix
{
  int i = threadIdx.x;
    int j = blockIdx.x;
        b[i*N+j]=a[i*N+j];
}

__global__ void roundOff(float *mat)
{
  int i = threadIdx.x;
    int j = blockIdx.x;
            if(mat[i*N+j]>=0)
            mat[i*N+j]=(int)(mat[i*N+j]+0.5);
            else
            mat[i*N+j]=(int)(mat[i*N+j]-0.5);    
}
__global__ void matMul(float *a, float *b,float *c,int n){
    int i = threadIdx.x;
    int j = blockIdx.x;
    c[i*N+j]=0;
        for(int k=0;k<n;k++)
            c[i*N+j] += a[i*N+k]*b[k*N+j];
}


__global__ void PrintInverse(float *ar)
{
  int i = threadIdx.x;
    int j = blockIdx.x;
            printf("%f ", ar[i*N+j]);
    
}
__global__ void add(float *a, float *b){
    int i = threadIdx.x;
    int j = blockIdx.x;
        a[i*N+j] += b[i*N+j];
}


__global__ void nodiag_normalize(float *A, float *I, int n, int i){            
int x = blockIdx.x * blockDim.x + threadIdx.x;
int y = blockIdx.y * blockDim.y + threadIdx.y;

if (x < n && y < n)
if (x == i && x!=y){
I[x*n + y] /= A[i*n + i];
A[x*n + y] /= A[i*n + i];
}

}

__global__ void diag_normalize( float *A, float *I, int n, int i){            
int x = blockIdx.x * blockDim.x + threadIdx.x;
int y = blockIdx.y * blockDim.y + threadIdx.y;

if (x < n && y < n)
if (x == y && x == i){
I[x*n + y] /= A[i*n + i];
A[x*n + y] /= A[i*n + i];
}

}

__global__ void gaussjordan( float*A,  float*I, int n, int i)
{
int x = blockIdx.x * blockDim.x + threadIdx.x;
int y = blockIdx.y * blockDim.y + threadIdx.y;

if (x < n && y < n){
if (x != i){
I[x*n + y] -= I[i*n + y] * A[x*n + i];
if (y != i){
A[x*n + y] -= A[i*n + y] * A[x*n + i];
}    
}
}

}

__global__ void set_zero( float*A, float*I, int n, int i){
int x = blockIdx.x * blockDim.x + threadIdx.x;
int y = blockIdx.y * blockDim.y + threadIdx.y;

if (x < n && y < n){
if (x != i){
if (y == i){
A[x*n + y] = 0;
}
}
}
}


int main(void)
{
    
    for(int i=0;i<N;i++)
        for(int j=0; j<N; j++)
            {
          if(i==j)
                     U[i*N+j]=1.0;
            else
             U[i*N+j]=0.0;
      }

float time;
cudaError_t err;
cudaEvent_t start, stop;
cudaEventCreate(&start);
cudaEventCreate(&stop);
    
  for(int i=0;i<N;i++)
        for(int j=0; j<N; j++)
                {
                    R[i*N+j]=rand()%256;
                    M[i*N+j]=rand()%256;
                    E[i*N+j]=rand()%2;
                }    
    float *d_r, *d_m, *d_e,*d_b,*d_c,*d_rinv,*d_I,*d_uinv,*d_rec;
    float*d_final;
  cudaMalloc((void**)&d_r, N*N*sizeof(float));
    cudaMalloc((void**)&d_m, N*N*sizeof(float));
    cudaMalloc((void**)&d_e, N*N*sizeof(float));
    cudaMalloc((void**)&d_b, N*N*sizeof(float));
    cudaMalloc((void**)&d_c, N*N*sizeof(float));
    cudaMalloc((void**)&d_I, N*N*sizeof(float));
    cudaMalloc((void**)&d_rinv, N*N*sizeof(float));
    cudaMalloc((void**)&d_uinv, N*N*sizeof(float));
    cudaMalloc((void**)&d_rec, N*N*sizeof(float));
    cudaMalloc((void**)&d_final, N*N*sizeof(float));

cudaMemcpy(d_I, U, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_r, R, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_b, B, N*N*sizeof(float) , cudaMemcpyHostToDevice);

  cudaEventRecord(start, 0);
     matMul<<<N,N>>>(d_I,d_r, d_b, N);
cudaMemcpy(B,d_b,  N*N*sizeof(float) , cudaMemcpyDeviceToHost);
printf("\nB:");
    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",B[i*N+j]);
        printf("\n");
    }

    printf("\n\n");
cudaMemcpy(d_m, M, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_c, C, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_b, B, N*N*sizeof(float) , cudaMemcpyHostToDevice);

    
     matMul<<<N,N>>>(d_m,d_b, d_c, N);
  cudaMemcpy(C,d_c,  N*N*sizeof(float) , cudaMemcpyDeviceToHost);
printf("\nC:");
    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",C[i*N+j]);
        printf("\n");
    }
 cudaMemcpy(d_c, C, N*N*sizeof(float) , cudaMemcpyHostToDevice);
 cudaMemcpy(d_e, E, N*N*sizeof(float) , cudaMemcpyHostToDevice);
   
     add<<<N,N>>>(d_c,d_e);
    
   cudaMemcpy(C,d_c,  N*N*sizeof(float) , cudaMemcpyDeviceToHost);

//END OF ENCRYPTION   
 printf("Rinv:\n");
    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
         { Rinv[i*N+j]=R[i*N+j];


            
printf("%f ",Rinv[i*N+j]);
   }    
 printf("\n");
    }   

//cudaMemcpy(d_r, R, N*N*sizeof(float) , cudaMemcpyHostToDevice);
//cudaMemcpy(d_rinv, Rinv, N*N*sizeof(float) , cudaMemcpyHostToDevice);
//matCopy<<<N,N>>>(d_r,d_rinv);
//cudaMemcpy(Rinv,d_rinv, N*N*sizeof(float) , cudaMemcpyDeviceToHost);



 cudaMemcpy(d_rinv, Rinv, N*N*sizeof(float) , cudaMemcpyHostToDevice);


 cudaMemcpy(d_I, U, N*N*sizeof(float) , cudaMemcpyHostToDevice);
dim3 threadsPerBlock(blocksize, blocksize);
dim3 numBlocks((N + blocksize - 1) / blocksize, (N + blocksize - 1) / blocksize);

for (int i = 0; i<N; i++){
nodiag_normalize << <numBlocks, threadsPerBlock >> >(d_rinv, d_I, N, i);
diag_normalize << <numBlocks, threadsPerBlock >> >(d_rinv, d_I, N, i);
gaussjordan << <numBlocks, threadsPerBlock >> >(d_rinv, d_I, N, i);
set_zero << <numBlocks, threadsPerBlock >> >(d_rinv, d_I, N, i);
}
    cudaMemcpy(Rinv,d_I, N*N*sizeof(float) , cudaMemcpyDeviceToHost);
printf("***********After inverse:Rinv:*****************");
for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",Rinv[i*N+j]);
        printf("\n");
    }
 //cudaMemcpy(d_I, U, N*N*sizeof(float) , cudaMemcpyHostToDevice);
 cudaMemcpy(d_uinv,Uinv, N*N*sizeof(float) , cudaMemcpyHostToDevice);
 matCopy<<<N,N>>>(d_I,d_uinv);
   cudaMemcpy(Uinv,d_uinv, N*N*sizeof(float) , cudaMemcpyDeviceToHost);
cudaMemcpy(d_uinv,Uinv, N*N*sizeof(float) , cudaMemcpyHostToDevice);
for (int i = 0; i<N; i++){
nodiag_normalize << <numBlocks, threadsPerBlock >> >(d_uinv, d_I, N, i);
diag_normalize << <numBlocks, threadsPerBlock >> >(d_uinv, d_I, N, i);
gaussjordan << <numBlocks, threadsPerBlock >> >(d_uinv, d_I, N, i);
set_zero << <numBlocks, threadsPerBlock >> >(d_uinv, d_I, N, i);
}
    cudaMemcpy(Uinv,d_uinv, N*N*sizeof(float) , cudaMemcpyDeviceToHost);
    
cudaMemcpy(d_rinv, Rinv, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_c, C, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_rec, REC, N*N*sizeof(float) , cudaMemcpyHostToDevice);

    
     matMul<<<N,N>>>(d_c,d_rinv, d_rec, N);
  cudaMemcpy(REC,d_rec,  N*N*sizeof(float) , cudaMemcpyDeviceToHost);
printf("\nREC:");
    
        for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",REC[i*N+j]);
        printf("\n");
    }

    printf("\n\n");
  cudaMemcpy(d_rec, REC, N*N*sizeof(float) , cudaMemcpyHostToDevice);
  roundOff<<<N,N>>>(d_rec);
    
    cudaMemcpy(REC,d_rec,  N*N*sizeof(float) , cudaMemcpyDeviceToHost);
 printf("\nAfter Roundoff REC:");
    
        for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",REC[i*N+j]);
        printf("\n");
    }

    printf("\n\n");
  cudaMemcpy(d_uinv, Uinv, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_final, Final, N*N*sizeof(float) , cudaMemcpyHostToDevice);
cudaMemcpy(d_rec, REC, N*N*sizeof(float) , cudaMemcpyHostToDevice);

    
     matMul<<<N,N>>>(d_rec,d_uinv, d_final, N);
  cudaMemcpy(Final,d_final,  N*N*sizeof(float) , cudaMemcpyDeviceToHost);
printf("\n Final:");
    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",Final[i*N+j]);
        printf("\n");
    }
    printf("\n\n");


    for(int i=0;i<N;i++)
    {
        for(int j=0;j<N;j++)
            printf("%f ",Final[i*N+j]-M[i*N+j]);
        printf("\n");
    }

    printf("\n\n");  
   
cudaEventRecord(stop, 0);
cudaEventSynchronize(stop);
cudaEventElapsedTime(&time, start, stop);
cudaEventDestroy(start);
cudaEventDestroy(stop);
   printf("\nTime taken is: %f",time);
   
cudaFree(d_I);
cudaFree(d_m);
cudaFree(d_r);
cudaFree(d_b);
cudaFree(d_rec);
cudaFree(d_rinv);
cudaFree(d_final);
cudaFree(d_uinv);
cudaFree(d_e);
return 0;
}

/*
'\nB:103.000000 115.000000 74.000000 \n205.000000 242.000000 70.000000 \n84.000000 232.000000 118.000000 \n\n\n\nC:56823.000000 97124.000000 48170.000000 \n81029.000000 110900.000000 45966.000000 \n80459.000000 105302.000000 45142.000000 \nRinv:\n103.000000 115.000000 74.000000 \n205.000000 242.000000 70.000000 \n84.000000 232.000000 118.000000 \n***********After inverse:Rinv:*****************0.010454 0.003054 -0.008368 \n-0.015542 0.005040 0.006757 \n0.023116 -0.012084 0.001147 \n\nREC:198.017899 80.995987 235.999512 \n185.994766 251.008133 123.998329 \n247.994797 231.008118 89.998367 \n\n\n\nAfter Roundoff REC:198.000000 81.000000 236.000000 \n186.000000 251.000000 124.000000 \n248.000000 231.000000 90.000000 \n\n\n\n Final:198.000000 81.000000 236.000000 \n186.000000 251.000000 124.000000 \n248.000000 231.000000 90.000000 \n\n\n\nDifference0.000000 0.000000 0.000000 \n0.000000 0.000000 0.000000 \n0.000000 0.000000 0.000000 \n\n\n\nTime taken is: 0.688544'
*/
