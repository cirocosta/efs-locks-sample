/**
 * DESCRIPTION
 *
 *      Creates N files and keeps a lock on each of them
 *      making use of `fcntl`.
 *
 *
 * USAGE
 *
 *      locks <number of files to take a lock to>
 *
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/file.h>
#include <sys/stat.h>
#include <sys/types.h>

typedef struct runtime_t {
	int number_of_locks;
	char* base_directory;
} runtime_t;

/**
 * Prints to STODUT the runtime configuration passed.
 */
void
runtime_show(runtime_t* runtime)
{
	printf("\n"
	       "Runtime:\n"
	       "  BASE_DIRECTORY:  %s\n"
	       "  NUMBER_OF_LOCKS: %d\n"
	       "\n",
	       runtime->base_directory,
	       runtime->number_of_locks);
}

/**
 * Creates a file under a directory (base) with a number (i)
 * and then grabs a write lock to it.
 */
void
create_file(const char* base, const int i)
{
	FILE* fp;
	char* filename;
	struct flock lock = { 0 };
	int err = 0;

	lock.l_type = F_WRLCK;

	err = asprintf(&filename, "%s/file%d", base, i);
	if (err == -1) {
		fprintf(stderr, "Couldn't create name for file %d", i);
		exit(1);
	}

	fp = fopen(filename, "a");
	if (fp == NULL) {
		fprintf(stderr, "Couldn't create file %s", filename);
		exit(1);
	}

	err = fcntl(fileno(fp), F_SETLKW, &lock);
	if (err == -1) {
		perror("fcntl");
		fprintf(stderr, "Couldn't acquire lock on %s", filename);
		exit(1);
	}

	fprintf(fp, "dummy");

	free(filename);
}

/**
 * Creates `N` files with write a write lock grabbed for each
 * under a base directory `base`.
 */
void
runtime_create_files(runtime_t* runtime)
{
	struct stat st = { 0 };
	int i = 0;
	int err = 0;

	printf("creating directory for files at '%s'\n",
	       runtime->base_directory);

	err = stat(runtime->base_directory, &st);
	if (err != -1) {
		perror("stat");
		fprintf(stderr,
		        "ERROR:\n"
		        "  Directory %s already exists.\n"
		        "  Please delete it and rerun.\n",
		        runtime->base_directory);
		exit(1);
	}

	err = mkdir(runtime->base_directory, 0700);
	if (err == -1) {
		perror("mkdir");
		fprintf(stderr,
		        "ERROR:\n"
		        "  Couldn't create directory %s\n",
		        runtime->base_directory);
		exit(1);
	}

	for (; i++ < runtime->number_of_locks;) {
		create_file(runtime->base_directory, i);
	}
}

/**
 * Main execution.
 *
 * Parses the cli arguments (number of locks
 * and base directory) and then starts the creation of the
 * files and locks.
 *
 * Once lock creation is done, pauses its execution until
 * a signal arrives.
 */
int
main(int argc, char** argv)
{
	setbuf(stdout, NULL);
	setbuf(stderr, NULL);

	if (argc < 3) {
		fprintf(stderr,
		        "ERROR:\n"
		        "  Not enough argument specified\n"
		        "  usage: %s <number_of_locks> <directory>\n",
		        argv[0]);
		exit(1);
	}

	runtime_t runtime = {
		.number_of_locks = atoi(argv[1]), .base_directory = argv[2],
	};

	runtime_show(&runtime);
	runtime_create_files(&runtime);

	printf("File successfully created.\n");
	printf("Waiting until signal.\n");

	pause();

	return 0;
}
