#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define N 100


float U[N][N],R[N][N],M[N][N],E[N][N],B[N][N],C[N][N],Final[N][N],I[N][N];
float Rinv[N][N],Uinv[N][N],REC[N][N];
float mat[N*N];

void initFeatures(char path[])
{
	int index = 0;
	FILE *f  = NULL;

	f = fopen(path, "r");
	//checkFile(f);

	while (fscanf(f, "%f%*c", &mat[index]) == 1) //%*c ignores the comma while reading the CSV
		index++;

	fclose(f);
	//return mat;
}

void matTo2D(float a[N*N],float b[N][N])
{
	for(int i=0;i<N;i++)
		for(int j=0;j<N;j++)
			b[i][j]=a[i*N+j];
}

void matCopy(float X[N][N],float Y[N][N])	//Copy X to Y
{
	for(int i=0;i<N;i++)
			for(int j=0;j<N;j++)
				Y[i][j]=X[i][j];
			
}

void matSwap(float X[N][N],float Y[N][N])	//Swap X and Y
{
	float temp;
	for(int i=0;i<N;i++)
			for(int j=0;j<N;j++)
				{
					temp=Y[i][j];
					Y[i][j]=X[i][j];
					X[i][j]=temp;
				}			
}

void rowSwap(int x, int y,float mat[N][N])
{
	int temp;
	for(int i=0;i<N;i++)
	{
		temp=mat[x][i];
		mat[x][i]=mat[y][i];
		mat[y][i]=temp;
		printf("hey!\n");
	}
}

void printMatrix(float A[N][N])
{
	
	for(int i=0;i<N;i++)
		{
			for(int j=0;j<N;j++)
				printf("%f ",A[i][j]);
			printf("\n");
		}

		printf("\n\n");		
}



void roundOff(float mat[][N])
{
	for(int i=0;i<N;i++)
		for(int j=0;j<N;j++)
			if(mat[i][j]>=0)
			mat[i][j]=(int)(mat[i][j]+0.5);
			else
			mat[i][j]=(int)(mat[i][j]-0.5);	
}

void matMul(float firstMatrix[][N], float secondMatrix[][N], float mult[][N])
{
	int i, j, k;

	// Multiplying matrix firstMatrix and secondMatrix and storing in array mult.
	for(i = 0; i < N; ++i)
	{
		for(j = 0; j < N; ++j)
		{
			for(k=0; k<N; ++k)
			{
				mult[i][j] += firstMatrix[i][k] * secondMatrix[k][j];
			}
		}
	}
}


void matAdd(float firstMatrix[][N], float secondMatrix[][N], float res[][N])
{
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<N;j++)
		{
			res[i][j]=firstMatrix[i][j]+secondMatrix[i][j];
		}
	}
}



void inverse(float A[N][N],float I[N][N])
{
	for(int i=0;i<N;i++)
	{
		if(A[i][i]==0)
		{
			for(int j=i;j<N;j++)
			{
				if(A[j][j]!=0)
					{rowSwap(j,i,A);break;}
			}
		}
		float scale=A[i][i];
		for(int col=0;col<N;col++)
		{
			A[i][col]=A[i][col]/scale;
			I[i][col]=I[i][col]/scale;
		}

		
		if(i<N-1)
		{
			for(int row=i+1;row<N;row++)
			{
				float factor=A[row][i];
				for(int col=0;col<N;col++)
				{
					A[row][col]=A[row][col]-factor*A[i][col];
					I[row][col]=I[row][col]-factor*I[i][col];
				}
			}
		}
	}
		
	for(int zcol=N-1;zcol>=1;zcol--)
	{
		for(int row=zcol-1;row>=0;row--)
		{
			float factor=A[row][zcol];
			for(int col=0;col<N;col++)
			{
				A[row][col]=A[row][col]-factor*A[zcol][col];
				I[row][col]=I[row][col]-factor*I[zcol][col];

			}
		}
	}	
}

int main()
{
	clock_t start, end;
	double total_time;
	start=clock();
	/*for(int i=0;i<10;i++)
		printf("%d ",rand());
	*/

	//Generate identity
	for(int i=0;i<N;i++)
		for(int j=0; j<N; j++)
			if(i==j)
				{
					U[i][j]=1;
					I[i][j]=1;
				}
	
	printf("\n\n");
	for(int i=0;i<N;i++)
		for(int j=0; j<N; j++)
				{
					R[i][j]=rand()%256;
					//M[i][j]=rand()%256;
					E[i][j]=rand()%2;
				}	
		
		printf("\n\nPrinting Mat\n\n");
	initFeatures("./mat.csv");	
	for(int i=0;i<N*N;i++)
		printf("%f ",mat[i]);
	printf("\n\n");
	matTo2D(mat,M);
	printMatrix(M);
	matMul(U,R,B);

	printMatrix(B);
	

	matMul(M,B,C);
	printMatrix(C);

	matAdd(C,E,C);				
	printMatrix(C);

	

	FILE *fc=fopen("SentMat.csv","w");
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<N;j++)
		{
			if(C[i][j]<0)
				C[i][j]=0;
			if(j<N-1)
			fprintf(fc,"%f,",C[i][j]);
			else
			fprintf(fc,"%f",C[i][j]);
		}

		fprintf(fc,"\n");
	}	
	//End of Encrption. Matrix C is the Matrix to be sent.
	//Starting Decryption


	matCopy(R,Rinv);
	inverse(Rinv,I);
	matSwap(Rinv,I);

	printMatrix(Rinv);
	printMatrix(I);
	
	matCopy(U,Uinv);
	inverse(Uinv,I);
	matSwap(Uinv,I);
	
	printMatrix(Uinv);
	printf("\n\n");

	matMul(C,Rinv,REC);
	
	printMatrix(REC);

	roundOff(REC);
	printMatrix(REC);

	matMul(REC,Uinv,Final);
	printMatrix(Final);

	for(int i=0;i<N;i++)
	{
		for(int j=0;j<N;j++)
			printf("%f ",Final[i][j]-M[i][j]);
		printf("\n");
	}
	end=clock();
	total_time=((double)(end - start))/CLOCKS_PER_SEC;
	printf("\nTime taken is: %f", total_time);

	FILE *fp=fopen("ReceivedMat.csv","w");
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<N;j++)
		{

			if(Final[i][j]<0)
				Final[i][j]=0;
			if(j<N-1)
			fprintf(fp,"%f,",Final[i][j]);
			else 
			fprintf(fp,"%f",Final[i][j]);	

		}
		fprintf(fp,"\n");
	}
	return 0;
}