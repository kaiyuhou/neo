#include "policy/reply-reachability.hpp"

#include <regex>

#include "process/forwarding.hpp"
#include "model.h"

ReplyReachabilityPolicy::ReplyReachabilityPolicy(
    const std::shared_ptr<cpptoml::table>& config, const Network& net,
    bool correlated)
    : Policy(correlated)
{
    parse_protocol(config);
    parse_pkt_dst(config);
    parse_owned_dst_only(config);
    parse_start_node(config, net);
    parse_tcp_ports(config);
    parse_query_node(config, net);
    parse_reachable(config);
}

void ReplyReachabilityPolicy::parse_query_node(
    const std::shared_ptr<cpptoml::table>& config, const Network& net)
{
    auto query_regex = config->get_as<std::string>("query_node");

    if (!query_regex) {
        Logger::get().err("Missing query node");
    }

    const std::map<std::string, Node *>& nodes = net.get_nodes();
    for (const auto& node : nodes) {
        if (std::regex_match(node.first, std::regex(*query_regex))) {
            query_nodes.insert(node.second);
        }
    }
}

void ReplyReachabilityPolicy::parse_reachable(
    const std::shared_ptr<cpptoml::table>& config)
{
    auto reachability = config->get_as<bool>("reachable");

    if (!reachability) {
        Logger::get().err("Missing reachability");
    }

    reachable = *reachability;
}

std::string ReplyReachabilityPolicy::to_string() const
{
    std::string ret = "reply-reachability [";
    for (Node *node : start_nodes) {
        ret += " " + node->to_string();
    }
    ret += " ] -> [";
    for (Node *node : query_nodes) {
        ret += " " + node->to_string();
    }
    ret += " ] -";
    if (reachable) {
        ret += "-";
    } else {
        ret += "X";
    }
    ret += "-> original sender";
    return ret;
}

void ReplyReachabilityPolicy::init(State *state) const
{
    state->violated = false;
}

void ReplyReachabilityPolicy::check_violation(State *state)
{
    bool reached;
    int mode = state->comm_state[state->comm].fwd_mode;
    uint8_t pkt_state = state->comm_state[state->comm].pkt_state;

    if (pkt_state == PS_HTTP_REP || pkt_state == PS_ICMP_ECHO_REP) {
        if (mode == fwd_mode::ACCEPTED) {
            Node *final_node;
            memcpy(&final_node, state->comm_state[state->comm].pkt_location,
                   sizeof(Node *));
            reached = (final_node == comm_tx);
        } else if (mode == fwd_mode::DROPPED) {
            reached = false;
        } else {
            /*
             * If the reply hasn't been accepted or dropped, there is nothing to
             * check.
             */
            return;
        }
        state->violated = (reachable != reached);
        state->choice_count = 0;
    } else {    // previous phases
        if ((mode == fwd_mode::ACCEPTED
                && query_nodes.count(comm_rx) == 0)
                || mode == fwd_mode::DROPPED) {
            reached = false;
        } else {
            /*
             * If the request (or session construction packets) hasn't been
             * accepted or dropped, there is nothing to check.
             */
            return;
        }
        if (!reached) {
            // precondition is false (request not received)
            state->violated = false;
            state->choice_count = 0;
        }
    }
}
