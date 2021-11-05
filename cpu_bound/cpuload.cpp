#include <cstdlib>
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <math.h>
#include <ctime>

using namespace std;


int main(int argc, char** argv)
{

	int value;
	bool isTimeMode = true;
	double res = 0;

	if (strcmp(argv[1],"-i") == 0){
		value = atoi(argv[2]);
		isTimeMode = false;
	}else 
		if(strcmp(argv[1],"-t") == 0){
			value = atoi(argv[2]);
		}else{
			cout << "Wrong parameters. Use -i for iteration or -t for time modes.\n";
			exit(-1);
		}

	if(isTimeMode){

		time_t start = time(nullptr);
		int i = 0;
		while (i < value){
			res+=sqrt(i)*sqrt(i);

			time_t now = time(nullptr);
			i = now - start;			
		}

		//for (int i = start; i < end; i++)res+=sqrt(i)*sqrt(i);
	}else{

		int start = 0;
		int end = value;

		for (int i = start; i < end; i++)res+=sqrt(i)*sqrt(i);
	}

	return 0;
}
