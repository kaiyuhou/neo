#pragma once

#include <string>

#include "lib/logger.hpp"
#include "topology.hpp"

class Plankton
{
private:
    Logger& logger;
    int max_jobs;
    std::string in_file, out_dir;

    Topology topology;
    //policies;

    void load_config();

public:
    Plankton(bool, bool, int, const std::string&, const std::string&);

    void run();
};
