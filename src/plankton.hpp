#pragma once

#include <string>
#include <list>

#include "network.hpp"
#include "policy/policy.hpp"
#include "process/forwarding.hpp"

/*
 * The state of the whole system consists of the network state and the states of
 * the (active) processes.
 */
class Plankton
{
private:
    size_t              max_jobs;   // degree of parallelism
    std::string         in_file;    // input TOML file
    std::string         out_dir;    // output directory
    Network             network;    // network information (inc. dataplane)
    std::list<Policy *> policies;

    /* per process variables */
    const EqClass   *ec;        // the EC being verified
    const Policy    *policy;    // the policy being verified

    /* processes */
    ForwardingProcess   fwd;

    Plankton();
    ~Plankton();
    int verify(const EqClass *, const Policy *);

public:
    // Disable the copy constructor and the copy assignment operator
    Plankton(const Plankton&) = delete;
    Plankton& operator=(const Plankton&) = delete;

    static Plankton& get_instance();

    void init(bool verbose, bool rm_out_dir, size_t dop,
              const std::string& input_file, const std::string& output_dir);
    void run();


    /*************************************************************/
    /******* functions called by the Promela network model *******/
    /*************************************************************/

    void initialize();
};
