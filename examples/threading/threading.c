#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...) printf("threading DEBUG: " msg "\n", ##__VA_ARGS__)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

// This function was partially generated using ChatGPT at https://chat.openai.com/ with prompts including
// "how can i wait in C" and "Where else would you add an error handler or debug function?".



void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
  struct thread_data* thread_func_args = (struct thread_data *) thread_param;
   
  DEBUG_LOG("Thread started with wait_to_obt_ms = %d, wait_to_rel_ms = %d",
             thread_func_args->wait_to_obt_ms, thread_func_args->wait_to_rel_ms);
  usleep((thread_func_args->wait_to_obt_ms)*1000); // for the milliseconds 
    //obtain
  pthread_mutex_lock(thread_func_args->mutex);
  DEBUG_LOG("Mutex locked.");
    
  usleep((thread_func_args->wait_to_rel_ms)*1000); 

  pthread_mutex_unlock(thread_func_args->mutex);
  DEBUG_LOG("Mutex unlocked.");


  thread_func_args->thread_complete_success = true;
  DEBUG_LOG("Thread started successfully."); 
  return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    struct thread_data* data = (struct thread_data*) malloc(sizeof(struct thread_data));
   if(data == NULL) {
     ERROR_LOG("Failed to allocate memory for thread_data.");
     return false;
   }

   data->mutex = mutex;
   data->wait_to_obt_ms = wait_to_obtain_ms;
   data->wait_to_rel_ms = wait_to_release_ms;
   data->thread_complete_success = false;
   
   int start_thread = pthread_create(thread, NULL, threadfunc, data);
  if (start_thread != 0) {
        ERROR_LOG("Thread creation failed with error code %d.", start_thread);
        free(data);
        return false;
    }
  return true;
}
