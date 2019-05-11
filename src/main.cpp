#include <getopt.h>
#include <cstdlib>
#include <iostream>
#include <string>

#include "plankton.hpp"


static void usage(const std::string& progname)
{
    std::cout <<
              "Usage: " + progname + " [-h] -i <dir> -o <dir>\n"
              "    -h, --help             print this help message\n"
              "    -i, --input <dir>      input directory\n"
              "    -o, --output <dir>     output directory\n";
}

static void parse_args(int argc, char **argv, std::string& input_dir,
                       std::string& output_dir)
{
    int opt;
    const char *optstring = "hi:o:";

    const struct option longopts[] = {
        {"help",       no_argument,       0, 'h'},
        {"input",      required_argument, 0, 'i'},
        {"output",     required_argument, 0, 'o'},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, optstring, longopts, NULL)) != -1) {
        switch (opt) {
            case 'h':
                usage(argv[0]);
                exit(EXIT_SUCCESS);
            case 'i':
                input_dir = optarg;
                break;
            case 'o':
                output_dir = optarg;
                break;
            default:
                usage(argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    if (input_dir.empty()) {
        std::cerr << "Error: missing input directory" << std::endl
                  << "Try '" << argv[0] << " --help' for more information"
                  << std::endl;
        exit(EXIT_FAILURE);
    }
    if (output_dir.empty()) {
        std::cerr << "Error: missing output directory" << std::endl
                  << "Try '" << argv[0] << " --help' for more information"
                  << std::endl;
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char **argv)
{
    std::string input_dir, output_dir;
    parse_args(argc, argv, input_dir, output_dir);

    Plankton plankton(input_dir, output_dir);
    plankton.run();

    return EXIT_SUCCESS;
}
