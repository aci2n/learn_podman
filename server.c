#include <microhttpd.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define PORT 8080

void sigint_handler(int sig) {
  printf("Received SIGINT (Ctrl+C)\n");
  // Perform any cleanup tasks here if necessary

  // Terminate the program with status 0
  exit(0);
}

static enum MHD_Result
answer_to_connection(void *cls, struct MHD_Connection *connection,
                     const char *url, const char *method, const char *version,
                     const char *upload_data, size_t *upload_data_size,
                     void **con_cls) {
  struct MHD_Response *response;
  int ret;

  if (NULL == cls) {
    response = MHD_create_response_from_buffer(5, (void *)"HELLO",
                                               MHD_RESPMEM_PERSISTENT);
  } else {
    printf("Unexpected second request.\n");
    return MHD_NO;
  }

  ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
  MHD_destroy_response(response);

  if (MHD_YES != ret) {
    return ret;
  }

  return MHD_YES;
}

int main() {
  if (signal(SIGINT, sigint_handler) == SIG_ERR) {
    perror("signal");
    return EXIT_FAILURE;
  }

  struct MHD_Daemon *daemon;

  daemon = MHD_start_daemon(MHD_USE_SELECT_INTERNALLY, PORT, NULL, NULL,
                            answer_to_connection, NULL, MHD_OPTION_END);
  if (NULL == daemon) {
    fprintf(stderr, "Failed to start the web server.\n");
    return 1;
  }

  printf("Listening on port %d...\n", PORT);

  sleep(-1);

  MHD_stop_daemon(daemon);
  return EXIT_SUCCESS;
}
