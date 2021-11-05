/* 
  This monitor uses the following code to be daemonized.
  http://www.enderunix.org/documents/eng/daemon.php  

  To terminate: kill `cat /tmp/smartpower_m.lock`
 */

#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <ctime>
#include <signal.h>
#include <sys/stat.h>

#define BUFLEN 24
#define RUNNING_DIR "/tmp"
#define LOCK_FILE   "smartpower_m.lock"
#define LOG_FILE    "/tmp/smartpower_m.log"
#define COUNTER_FILE "counter_power.csv"

using namespace std;

int sock;
ofstream smartpower_data;

long int unix_timestamp(){
    time_t t = time(0);
    long int now = static_cast<long int> (t);
    return now;
}

void log_message(const char *message){
    time_t rawtime;
    struct tm * timeinfo;
    time (&rawtime);
    char now [80];

    ofstream log(LOG_FILE, std::ofstream::out | std::ofstream::app);
    timeinfo = localtime (&rawtime);

    strftime(now,80,"%c",timeinfo);

    log << now << " : "  << message << endl; 

    log.flush();
    log.close();
}

void signal_handler(int sig){

    switch(sig) {
    case SIGHUP:
        log_message("hangup signal catched");
        break;
    case SIGTERM:
        log_message("terminate signal catched");

        smartpower_data.close();
        close(sock);

        exit(0);
        break;
    }
}

void daemonize(){

    log_message("Daemonizing..");

    int i,lfp;
    char str[10];

    if(getppid()==1) {
        log_message("already a daemon");
        return; /* already a daemon */
    }

    i=fork();

    if (i<0){
        log_message("fork error");
        exit(1); /* fork error */
    }
    if (i>0){
        log_message("parent exits");
        exit(0); /* parent exits */
    }

    /* child (daemon) continues */
    setsid(); /* obtain a new process group */

    for (i=getdtablesize();i>=0;--i) 
        close(i); /* close all descriptors */
    
    i=open("/dev/null",O_RDWR); dup(i); dup(i); /* handle standart I/O */
    
    umask(027); /* set newly created file permissions */
    
    chdir(RUNNING_DIR); /* change running directory */
    
    lfp=open(LOCK_FILE,O_RDWR|O_CREAT,0640);
    if (lfp<0){
        log_message("LOCK_FILE can not open ");
        exit(1); /* can not open */
    }
    if (lockf(lfp,F_TLOCK,0)<0){
        log_message("LOCK_FILE can not be locked ");
        exit(0); /* can not lock */
    }
    
    /* first instance continues */
    sprintf(str,"%d\n",getpid());
    write(lfp,str,strlen(str)); /* record pid to lockfile */
    
    signal(SIGCHLD,SIG_IGN); /* ignore child */
    signal(SIGTSTP,SIG_IGN); /* ignore tty signals */
    signal(SIGTTOU,SIG_IGN);
    signal(SIGTTIN,SIG_IGN);
    signal(SIGHUP,signal_handler); /* catch hangup signal */
    signal(SIGTERM,signal_handler); /* catch kill signal */
    
    log_message("Daemonized done");
}

int main(int argc , char *argv[]) {

    daemonize();

    if (argc < 4) {
        log_message("Usage: smart_monitor address [port] smart_monitor_file\n");
        return 1;
    }
    
    unsigned char buf[BUFLEN];
    int port = atoi(argv[2]);
    smartpower_data.open(argv[3]);

    //Create socket
    if ((sock = socket(AF_INET , SOCK_STREAM , 0)) < 0) {
        log_message("Could not create socket. Error");
        return 1;
    }
 
    struct sockaddr_in server;
    server.sin_addr.s_addr = inet_addr(argv[1]);
    server.sin_family = AF_INET;
    server.sin_port = htons(port);
 
    //Connect to remote server
    if (connect(sock , (struct sockaddr *)&server , sizeof(server)) < 0) {
        log_message("connect failed. Error");
        return 1;
    }

    log_message("Connected...\n");

    while (1) {
 //log_message("***New Loop***");

            int rv;
            if ((rv = recv(sock , buf , sizeof(buf) , 0)) < 0)
                return 1;
            else if (rv == 0) {
                log_message("Connection closed by the remote end\n\r");
                return 0;
            }
            
            if(rv == 24){
                
                string sbuf (reinterpret_cast<char*>(buf));
                istringstream isbuf(sbuf);
                vector<string> v;
                string data;
                
                //log_message(sbuf.c_str());

                while(getline(isbuf,data,','))
                    v.push_back(data);

                ofstream counter_power(COUNTER_FILE);
                if (counter_power.is_open( )){
                    counter_power << v[2] << "," << v[3] << endl;
                    counter_power.flush();
                    counter_power.close();
                }else
                    log_message("error to open counter_power file");
                
                if (smartpower_data.is_open( )){
                    long long int now = unix_timestamp();
                    smartpower_data << now << ","<< v[0] << "," << v[1] << "," << v[2] << "," << v[3] << endl; 
                    smartpower_data.flush();
                }else
                    log_message("error to open smartpower_data file");
            }
    }

    smartpower_data.close();

    close(sock);
    return 0;
}
