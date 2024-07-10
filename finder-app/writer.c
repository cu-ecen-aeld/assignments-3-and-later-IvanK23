#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/syslog.h>
#include <syslog.h>
#include <unistd.h>

const unsigned int NUMBER_OF_ARGUMENTS = 3;

int main(int argc, char** argv){
  
  const char* writefile = argv[1];
  const char* writestr = argv[2];

  openlog("Writing program", LOG_PID, LOG_USER);

  if(argc < NUMBER_OF_ARGUMENTS){
    // write error function
    syslog(LOG_ERR, "ERROR: Any of the arguments above were not specified: %d", argc);
    fprintf(stderr, "Error: Incorrect number of arguments.\n");
    closelog();
    return 1;
  }

  int fd = open(writefile, O_WRONLY | O_CREAT | O_TRUNC , 0644);
  if(fd == -1 ) {
    syslog(LOG_ERR, "ERROR: Can not create the file %s !", writefile);
    closelog();
    return 1;
  }
  size_t sizeOfStr = strlen(writestr);
  
  ssize_t writeToFile = write(fd, writestr, sizeOfStr);

  if(writeToFile == -1 ){
    syslog(LOG_ERR,"ERROR: Can not write %s to %s", writestr, writefile);
    close(fd);
    closelog();
    return 1;

  } 
  else if( writeToFile != sizeOfStr) {
    syslog(LOG_ERR, "Something going wrong...");
    close(fd);
    closelog();
    return 1;
  }else {
// This function was partially generated using ChatGPT at https://chat.openai.com/ with prompts including 
// \"how to write \"\n\" to the file?\".

    writeToFile = write(fd, "\n", 1);
    syslog(LOG_DEBUG, "Writing %s to %s .", writestr, writefile);
  }
  close(fd);
  closelog();

  return 0;
}

