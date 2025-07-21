#include <stdio.h>
#include <curl/curl.h>

// Callback function to handle incoming data
size_t write_callback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t totalSize = size * nmemb;
    printf("%.*s", (int)totalSize, (char *)contents);
    return totalSize;
}

int main() {
    CURL *curl;
    CURLcode res;

    // Initialize a curl session
    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if(curl) {
        // Set the URL to fetch data from
        curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:8080");

        // Set the callback function to handle incoming data
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);

        // Perform the request, res will get the return code
        res = curl_easy_perform(curl);
        // Check for errors
        if(res != CURLE_OK)
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));

        // Always cleanup
        curl_easy_cleanup(curl);
    }
    curl_global_cleanup();

    return 0;
}

