#pragma once

#include <vector>
#include <unordered_set>

#include "process/process.hpp"
#include "node.hpp"

enum fwd_mode {
    // start from 1 to avoid execution before configuration
    FORWARD_PACKET = 1,
    COLLECT_NHOPS = 2,
    ACCEPTED = 3,
    DROPPED = 4
};

struct CandHash {
    size_t operator()(const std::vector<Node *> *const&) const;
};

struct CandEq {
    bool operator()(const std::vector<Node *> *const&,
                    const std::vector<Node *> *const&) const;
};

class ForwardingProcess : public Process
{
private:
    std::unordered_set<std::vector<Node *> *, CandHash, CandEq> candidates_hist;

    void update_candidates(State *, const std::vector<Node *>&);
    void forward_packet(State *) const;
    void collect_next_hops(State *);

public:
    ForwardingProcess() = default;
    ForwardingProcess(const ForwardingProcess&) = delete;
    ForwardingProcess(ForwardingProcess&&) = delete;
    ~ForwardingProcess();

    ForwardingProcess& operator=(const ForwardingProcess&) = delete;
    ForwardingProcess& operator=(ForwardingProcess&&) = delete;

    void config(State *, const std::vector<Node *>&);
    void exec_step(State *) override;
};
