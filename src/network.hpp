#pragma once

#include <map>
#include <set>
#include <unordered_set>
#include <string>
#include <vector>

#include "node.hpp"
#include "link.hpp"
#include "l2-lan.hpp"
class Middlebox;
class OpenflowProcess;
class Route;
struct State;

/*
 * A network is an undirected graph. Nodes and links will remain constant once
 * they are constructed from the network configurations.
 *
 * The state of a network consists of the current FIB (dataplane) and the failed
 * links.
 */
class Network
{
private:
    std::map<std::string, Node *>   nodes;
    std::set<Link *, LinkCompare>   links;
    std::unordered_set<Middlebox *> middleboxes;
    OpenflowProcess *openflow;

    std::unordered_set<L2_LAN *> l2_lans;   // history L2 LANs

private:
    friend class Config;
    void add_node(Node *);
    void add_link(Link *);
    void add_middlebox(Middlebox *);
    void grow_and_set_l2_lan(Node *, Interface *);

public:
    Network() = default;
    Network(const Network&) = delete;
    Network(Network&&) = default;
    ~Network();

    Network& operator=(const Network&) = delete;
    Network& operator=(Network&&) = default;

    const std::map<std::string, Node *>& get_nodes() const;
    const std::set<Link *, LinkCompare>& get_links() const;
    const std::unordered_set<Middlebox *>& get_middleboxes() const;

    void init(State *, OpenflowProcess *ofp = nullptr);
    void update_fib(State *);   // update FIB according to the current EC

    // The failure agent/process is not implemented yet, but if a link fails,
    // the FIB would need to be updated. (A link failure will change the
    // "active_peers" of the related nodes, and hence potentially change the
    // FIB.)
};
